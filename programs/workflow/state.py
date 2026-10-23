#!/usr/bin/env python3
"""Fingerprint what the workflow manager reads, and wake it only when something changed.

`workflow-state tick` runs from launchd every five minutes. It gathers the world the manager's standup reads —
Keiran's open pull requests, the ones he is named to review, cards assigned to him, worktrees, the sessions
working in them, annotations and remarks — into one JSON graph under ~/.config/workflow, and compares it with
the graph the last tick kept. Nothing changed means nothing happens and no Claude is started. A change is
written to `last-change.md`, shown as a notification, and passed to the manager session by a one-shot Claude
whose only job is to send that message, since nothing outside Claude can message a session.

    workflow-state gather   print the graph
    workflow-state diff     print what changed since the last tick, keeping nothing
    workflow-state tick     keep the graph, and wake the manager if anything changed
    workflow-state wake     send the manager the last change again
    workflow-state status   the last tick, and the last change
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

STATE_DIRECTORY = Path.home() / ".config/workflow"
STATE_FILE = STATE_DIRECTORY / "state.json"
LAST_CHANGE_FILE = STATE_DIRECTORY / "last-change.md"
CHANGES_LOG = STATE_DIRECTORY / "changes.log"
WATCH_LOG = STATE_DIRECTORY / "watch.log"

REPOSITORY = Path.home() / "Code/lookout"
WORKTREES = Path.home() / "Code/worktrees/lookout"  # Where the `worktrees` skill puts them; sessions in here count
BASECAMP_PROJECT = "48558737"  # CDP: Unified memberships
CARD_TABLES = {"10216489481": "Multi-funding scheme", "10345002758": "Card Table 2"}
KEIRAN_IN_BASECAMP = 32600820
MANAGER = os.environ.get("WORKFLOW_MANAGER", "manager")  # The session's `--name`, as ListAgents shows it

CLAUDE_SESSIONS = Path.home() / ".claude/sessions"
ANNOTATIONS = Path.home() / ".config/paddck/annotations"


class SourceFailed(Exception):
    """A source could not be read, so no diff this tick: a dead `gh` is not thirty pull requests closing."""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("verb", choices=["gather", "diff", "tick", "wake", "status"])
    verb = parser.parse_args().verb
    STATE_DIRECTORY.mkdir(parents=True, exist_ok=True)
    return {"gather": gather_verb, "diff": diff_verb, "tick": tick, "wake": wake_verb, "status": status}[verb]()


def gather_verb() -> int:
    print(json.dumps(gather(load_state()), indent=2))
    return 0


def diff_verb() -> int:
    previous = load_state()
    if not previous:
        print("no previous tick to diff against")
        return 1
    print("\n".join(changes(previous, gather(previous))) or "no change")
    return 0


def tick() -> int:
    previous = load_state()
    try:
        current = gather(previous)
    except SourceFailed as failure:
        log(f"tick skipped: {failure}")
        return 1

    save_state(current)
    if not previous:
        log("first tick: graph recorded, nothing to compare")
        return 0

    lines = changes(previous, current)
    if not lines:
        log("no change")
        return 0

    record_change(lines)
    notify(lines)
    wake(lines)
    return 0


def wake_verb() -> int:
    if not LAST_CHANGE_FILE.exists():
        print("nothing has changed yet")
        return 1
    wake(LAST_CHANGE_FILE.read_text().splitlines()[2:])
    return 0


def status() -> int:
    state = load_state()
    print(f"last tick     {state.get('gathered_at', 'never')}")
    for collection in ("pull_requests", "review_requests", "cards", "worktrees", "sessions", "annotations", "review_windows"):
        print(f"  {collection:16} {len(state.get(collection, []))}")
    print(f"  {'remarks':16} {sum(state.get('remarks', {}).values())}")
    if LAST_CHANGE_FILE.exists():
        print(f"\nlast change\n{LAST_CHANGE_FILE.read_text()}")
    if WATCH_LOG.exists():
        print("log\n" + "".join(WATCH_LOG.read_text().splitlines(keepends=True)[-5:]))
    return 0


# Gathering


def gather(previous: dict) -> dict:
    known = {pr["number"]: pr for pr in previous.get("pull_requests", []) + previous.get("review_requests", [])}
    worktree_list = worktrees()
    return {
        "gathered_at": now(),
        "pull_requests": [pull_request(listing, known) for listing in authored_pull_requests()],
        "review_requests": [pull_request(listing, known) for listing in review_requested_pull_requests()],
        "cards": cards_assigned_to_keiran(),
        "worktrees": worktree_list,
        "sessions": sessions(),
        "annotations": annotations(),
        "remarks": remarks(worktree_list),
        "review_windows": review_windows(),
    }


PULL_REQUEST_FIELDS = "number,title,url,headRefName,author,isDraft,reviewDecision,statusCheckRollup,updatedAt"
PULL_REQUEST_AGE_DAYS = 30  # Older drafts are parked, not in flight; one that wakes up re-enters by being touched


def authored_pull_requests() -> list[dict]:
    return open_pull_requests("author:@me")


def review_requested_pull_requests() -> list[dict]:
    # Named reviews only: `review-requested:@me` would include requests that reach him through a team
    return open_pull_requests("user-review-requested:@me")


def open_pull_requests(search: str) -> list[dict]:
    since = (datetime.now(timezone.utc) - timedelta(days=PULL_REQUEST_AGE_DAYS)).date().isoformat()
    return json.loads(run("gh", "pr", "list", "--search", f"{search} updated:>={since}", "--state", "open", "--limit", "100", "--json", PULL_REQUEST_FIELDS, cwd=REPOSITORY))


def pull_request(listing: dict, known: dict) -> dict:
    number = listing["number"]
    pull_request = {
        "number": number,
        "title": listing["title"],
        "url": listing["url"],
        "branch": listing["headRefName"],
        "author": (listing.get("author") or {}).get("login"),
        "draft": listing["isDraft"],
        "review_decision": listing.get("reviewDecision") or "",
        "ci": ci_summary(listing.get("statusCheckRollup") or []),
        "updated_at": listing["updatedAt"],
    }

    # GitHub bumps updated_at on any comment or review, so counts are only re-fetched for a pull request that moved
    before = known.get(number)
    if before and before["updated_at"] == pull_request["updated_at"]:
        counts = {field: before[field] for field in ("reviews", "comments", "review_comments")}
    else:
        counts = conversation_counts(number)
    return {**pull_request, **counts}


def ci_summary(rollup: list[dict]) -> str:
    states = {check.get("conclusion") or check.get("state") for check in rollup}
    if states & {"FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED"}:
        return "failing"
    if states & {"PENDING", "IN_PROGRESS", "QUEUED", "EXPECTED", "WAITING"}:
        return "pending"
    if states:
        return "passing"
    return "none"


def conversation_counts(number: int) -> dict:
    view = json.loads(run("gh", "pr", "view", str(number), "--json", "reviews,comments", cwd=REPOSITORY))
    pages = run("gh", "api", "--paginate", f"repos/{{owner}}/{{repo}}/pulls/{number}/comments", "--jq", "length", cwd=REPOSITORY)
    return {
        "reviews": len(view["reviews"]),
        "comments": len(view["comments"]),
        "review_comments": sum(int(page) for page in pages.split()),
    }


def cards_assigned_to_keiran() -> list[dict]:
    cards = []
    for table_id, table in CARD_TABLES.items():
        for card in json.loads(run("basecamp", "cards", "list", "--in", BASECAMP_PROJECT, "--card-table", table_id, "--agent")):
            assigned = any(person.get("id") == KEIRAN_IN_BASECAMP for person in card.get("assignees") or [])
            if card.get("completed") or not assigned:
                continue
            cards.append({
                "id": card["id"],
                "title": card["title"],
                "table": table,
                "column": (card.get("parent") or {}).get("title"),
                "comments": card.get("comments_count", 0),
                "due_on": card.get("due_on"),
                "url": card.get("app_url"),
            })
    return sorted(cards, key=lambda card: card["id"])


def worktrees() -> list[dict]:
    found, path = [], None
    for line in run("git", "worktree", "list", "--porcelain", cwd=REPOSITORY).splitlines():
        if line.startswith("worktree "):
            path = line.removeprefix("worktree ")
        elif line.startswith("branch ") and path:
            found.append({"path": path, "branch": line.removeprefix("branch refs/heads/")})
    return sorted(found, key=lambda worktree: worktree["path"])


def sessions() -> list[dict]:
    """The interactive sessions sitting in a worktree: engineers and reviewers, not Keiran's own windows."""
    found = []
    for file in CLAUDE_SESSIONS.glob("*.json"):
        session = json.loads(file.read_text())
        if session.get("kind") != "interactive" or not alive(session["pid"]):
            continue
        if not session["cwd"].startswith(str(WORKTREES)):
            continue
        found.append({"name": session["name"], "status": session["status"], "cwd": session["cwd"], "tmux": session.get("tmux")})
    return sorted(found, key=lambda session: session["name"])


def alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def annotations() -> list[dict]:
    found = []
    for file in ANNOTATIONS.glob("*.json"):
        annotation = json.loads(file.read_text())
        found.append({
            "worktree": annotation["subject"]["value"],
            "headline": annotation.get("headline"),
            "stage": (annotation.get("progress") or {}).get("label"),
            "links": {link["label"]: link["url"] for link in annotation.get("links", [])},
        })
    return sorted(found, key=lambda annotation: annotation["worktree"])


def remarks(worktree_list: list[dict]) -> dict:
    counts = {}
    for worktree in worktree_list:
        if not (Path(worktree["path"]) / ".remarks").is_dir():
            continue
        counts[worktree["path"]] = len(json.loads(run("remarks", "list", "--json", cwd=worktree["path"])))
    return counts


def review_windows() -> list[dict]:
    try:
        listing = run("tmux", "list-windows", "-t", "Review", "-F", "#W\t#{pane_current_path}")
    except SourceFailed:
        return []  # No Review session
    return sorted(({"name": name, "path": path} for name, path in (line.split("\t") for line in listing.splitlines())), key=lambda window: window["path"])


def run(*command: str, cwd: Path | str | None = None, timeout: int = 60) -> str:
    try:
        completed = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=timeout, stdin=subprocess.DEVNULL)
    except (OSError, subprocess.TimeoutExpired) as failure:
        raise SourceFailed(f"{command[0]}: {failure}") from failure
    if completed.returncode != 0:
        raise SourceFailed(f"{' '.join(command[:3])}: exit {completed.returncode}: {completed.stderr.strip()[:200]}")
    return completed.stdout


# Comparing


def changes(before: dict, after: dict) -> list[str]:
    lines = []
    lines += collection_changes("PR", before["pull_requests"], after["pull_requests"], "number", pull_request_label, ignore=("updated_at",))
    lines += collection_changes("review request", before["review_requests"], after["review_requests"], "number", pull_request_label, ignore=("updated_at",))
    lines += collection_changes("card", before["cards"], after["cards"], "id", lambda card: card["title"])
    lines += collection_changes("worktree", before["worktrees"], after["worktrees"], "path", lambda worktree: Path(worktree["path"]).name)
    lines += collection_changes("session", before["sessions"], after["sessions"], "name", lambda session: session["name"])
    lines += collection_changes("annotation", before["annotations"], after["annotations"], "worktree", lambda annotation: annotation["headline"])
    lines += collection_changes("remarks in", items_of(before["remarks"]), items_of(after["remarks"]), "path", lambda item: Path(item["path"]).name)
    lines += collection_changes("review window", before["review_windows"], after["review_windows"], "path", lambda window: Path(window["path"]).name)
    return lines


def pull_request_label(pull_request: dict) -> str:
    return f"#{pull_request['number']} {pull_request['title']}"


def items_of(counts: dict) -> list[dict]:
    return [{"path": path, "count": count} for path, count in counts.items()]


def collection_changes(kind: str, before: list[dict], after: list[dict], key: str, label, ignore: tuple = ()) -> list[str]:
    previous = {item[key]: item for item in before}
    current = {item[key]: item for item in after}
    lines = []
    for identity in current.keys() - previous.keys():
        lines.append(f"{kind} {label(current[identity])}: new")
    for identity in previous.keys() - current.keys():
        lines.append(f"{kind} {label(previous[identity])}: gone")
    for identity in current.keys() & previous.keys():
        old, new = previous[identity], current[identity]
        moved = [f"{field} {old.get(field)} → {new.get(field)}" for field in new if field not in ignore and old.get(field) != new.get(field)]
        if moved:
            lines.append(f"{kind} {label(new)}: {', '.join(moved)}")
    return sorted(lines)


# Acting on a change


def record_change(lines: list[str]) -> None:
    stamp = now()
    LAST_CHANGE_FILE.write_text(f"# Changed at {stamp}\n\n" + "".join(f"- {line}\n" for line in lines))
    with CHANGES_LOG.open("a") as changes_log:
        changes_log.write(f"{stamp}\n" + "".join(f"  {line}\n" for line in lines))
    log(f"{len(lines)} change(s): {lines[0]}" + (f" (+{len(lines) - 1})" if len(lines) > 1 else ""))


def notify(lines: list[str]) -> None:
    body = lines[0] + (f" and {len(lines) - 1} more" if len(lines) > 1 else "")
    subprocess.run(["osascript", "-e", f'display notification "{body.replace(chr(34), chr(39))}" with title "Workflow"'], capture_output=True)


def wake(lines: list[str]) -> None:
    if not manager_running():
        log(f"no session named {MANAGER!r} to wake")
        return

    message = (
        f"Workflow watcher: {len(lines)} change(s) since your last standup. "
        f"Read {LAST_CHANGE_FILE} for what moved and {STATE_FILE} for the world as it stands, then run your standup."
    )
    prompt = f"Use SendMessage to send the session named {MANAGER!r} exactly this message, then stop:\n\n{message}"
    try:
        run(
            "claude", "-p", prompt, "--model", "haiku", "--effort", "low",
            "--setting-sources", "", "--strict-mcp-config", "--mcp-config", '{"mcpServers": {}}',
            "--tools", "SendMessage,ListAgents", "--allowedTools", "SendMessage", "ListAgents",
            cwd=STATE_DIRECTORY, timeout=180,
        )
    except SourceFailed as failure:
        log(f"wake failed: {failure}")
        return
    log(f"woke {MANAGER!r}")


def manager_running() -> bool:
    for file in CLAUDE_SESSIONS.glob("*.json"):
        session = json.loads(file.read_text())
        if session.get("name") == MANAGER and session.get("kind") == "interactive" and alive(session["pid"]):
            return True
    return False


# State


def load_state() -> dict:
    if not STATE_FILE.exists():
        return {}
    return json.loads(STATE_FILE.read_text())


def save_state(state: dict) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n")


def log(line: str) -> None:
    with WATCH_LOG.open("a") as watch_log:
        watch_log.write(f"{now()} {line}\n")
    print(line)


def now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


if __name__ == "__main__":
    sys.exit(main())
