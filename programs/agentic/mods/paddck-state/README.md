# paddck-state

**What this Claude session is doing, told to paddck from inside it.**

Paddck learns what an agent is up to from the pane options `paddck hook claude` writes. Until now
the thing calling that was eight settings hooks, each one a shell script woken with its own payload
and no memory of the last. This is the same job done by a mod — a module loaded once into the
session that stays for the life of it — and paddck is untouched: what goes down the pipe is a Claude
lifecycle event of exactly the shape `hook.ts` already reads.

## Why a mod

Two facts the old wiring had to infer, and now does not have to.

**A finished subagent.** `SubagentStop` fires for a subagent the turn *waited* for and one it left
running, and the two payloads are identical. Paddck told them apart by reading back what the pane
already said, over tmux, on every one. The mod watched the foreground turn end, so it knows.

**Whether anything changed at all.** Every hook firing was a `bash` and a `bun`, most of them to
conclude that the pane already said what they were about to write. The mod holds the last thing it
said and spends a subprocess only on a transition.

## What a mod cannot do, and what that cost

There was a third claim here: that `tool.check` caught a permission prompt where the engine decides
to show one, rather than waiting on a `Notification` six seconds late. It was wrong, and it is worth
keeping the correction rather than the claim.

`ask` is not *a prompt was shown*. The types say so plainly — the verdict is "run the tool, put it
to **the mode's decider** (the dialog, the auto-mode classifier, a headless host), or refuse it" —
and under auto mode that decider is a classifier that answers in about a second and shows nobody
anything. So nearly every tool call reported `ask`, every one of them was sent on as a standing
permission prompt, and the pane read *waiting for you* for as long as each call took to run. A
minute-long spec run was a minute of a working agent asking to be rescued. Rows stopped being green.

Nor can the reading be repaired where it was made. `tool.check` resolves *before the mode settles an
ask*, and `tool.call`'s `next(e)` spans the prompt and the tool's own run as a single span — so
there is no moment in this file that means *the human answered*, as distinct from *the call
finished*. A timer armed on the ask and cancelled on the call would fire during every slow approved
call.

So the job went back to the one observer that has it: Claude's `Notification`, through a settings
hook that stays alongside this mod — see `claude.nix`. Late and true beats immediate and wrong.

What stays here is the tally. `tool.check` is still hooked, counts what the engine decided, and
sends nothing: the counts ride along on the events the mod does send, and surface in paddck's
diagnosis file beside a snapshot of the pane. A turn of fourteen asks against a pane nobody was
prompted on is the whole of the evidence, and it is now impossible to lose.

Clearing the amber is the mod's half of the bargain, and `announced` is the catch: it records what
*this mod* last sent, so a pane the settings hook turned amber still matches the mod's last
`working` and would be deduped into silence. The length of the call settles it. Claude raises that
notification six seconds after the fact at the earliest, so a call that returned faster cannot have
been prompted and dedupes as before; only a slower one sends `regardless`.

## What it listens to

| Event | Why this one | What paddck is told |
| --- | --- | --- |
| `session.start` | Before the first prompt. Not raised again by `/clear`, `/resume` or `/branch`, which is why identity is read per message rather than cached. | `SessionStart` |
| `turn.start` | A turn beginning. A subagent's run raises none, so every one of these is the foreground. | `UserPromptSubmit` |
| `agent.spawn` | A subagent starting. Counted, because the payload that used to carry the count was `Stop`'s. | nothing |
| `turn.complete` | The foreground's is the resting point — whatever is still running then is what the turn left behind. A subagent's says nothing until the foreground has already stopped. | `Stop`, with the running count |
| `tool.call` on `AskUserQuestion` | A question, as it is asked, and the far side of it in the same hook — answered, escaped out of or failed, the turn has it back either way. | `PreToolUse` then `PostToolUse` |
| `tool.check` | What the engine decided, counted and not acted on. `ask` does not mean anybody was asked. | nothing; the tally rides along |
| `tool.call` | The call has run, so the turn is moving again — said past the dedupe only when it ran long enough to have been prompted. | `UserPromptSubmit` |
| `session.end` | `e.reason` separates a real ending from `/clear` and `/resume`. | `SessionEnd` |

**No `classic.*` events.** The obvious design hooks `classic.SessionStart` and `classic.Stop` and
reuses the settings hooks' payloads. It does not work: the built-in guard bypasses those events for
a mod at user tier — `classic.SessionStart bypassed by cc-plugin-sec-default (tier user); beneath
runs` — so they never arrive, silently. Every signal here is mod-native for that reason.

**Everything on `$` is awaited.** `$.env.get` returns a promise like the rest, and a promise is
truthy, so a missing `await` does not fail: it spells `[object Promise]` into a path and the error
goes to the catch in `tell`. That cost an afternoon.

## What it does not do

**It does not touch tmux.** Paddck remains the only writer of pane options, and this remains a
sender of the vocabulary it already reads. Nothing here knows what a pane is.

**It does not report a standing permission prompt.** That is the settings `Notification` hook's, and
the section above is why.

**It says nothing new yet.** `$.session.usage()` would give a context-window percentage per row, and
`$.session.messages()` would retire the transcript scraping under `providers/agents/claude/transcript/`.
Both are worth having and neither is sent, because paddck has nowhere to put them — a field nobody
reads is not a feature. They are the next change, on paddck's side first.

**It is Claude's only.** opencode reaches paddck through its own plugin and `scripts/agents/state.sh`,
and that seam is unchanged.

## Running it

Two gates, and only the first is a version. Mods want Claude Code **2.1.287 or later**; below that
a mod is not loaded and says nothing about it. Above it, whether a mod loads is also decided by a
switch Anthropic serves per process, which no local setting overrides. Measured here over thirteen
runs it served off three times, so roughly one session in five starts with no sender at all and
paddck's row holds whatever it last knew.

The cure is a new process: the switch is rolled afresh each time, and `claude --resume` picks the
conversation up and rolls again. The row going quiet is the symptom; this is the confirmation:

```bash
claude -p "hi" --debug-file /tmp/d.log
grep "hooks module paddck-state" /tmp/d.log
```

`claude plugin test` is not the check — it reports that mods can load without asking the server, so
it says yes while the switch is serving no.

Loaded from the checkout rather than installed from a marketplace, for the same reason the paddck
hook is a symlink: what you edit is what the next session loads, with no `switch` in between.

To see it working, open a session in tmux and watch the pane:

```bash
tmux show-options -p | grep paddck
```

`@paddck_state` should read `working` during a turn, `idle` when it ends with nothing outstanding,
`working` when it ends with subagents still running, and `question` while one is on screen. It
should read `waiting` only while a permission prompt is genuinely on screen — if it reads `waiting`
through an ordinary tool call, this mod has gone back to believing `tool.check`.

Everything the mod sends is also in paddck's own log at `~/.config/paddck/hooks.log`, and
`touch ~/.config/paddck/diagnose` puts every state change beside a snapshot of the pane that caused
it, under `~/.config/paddck/diagnosis/`. That is where the tally lands.
