---
name: obsidian
description: >
  Capture into and read from the Obsidian vault — the dated period notes (daily, weekly, monthly)
  and the effort notes that hold an initiative's durable understanding. Use whenever the user says
  "add this to today / this week / this month", "jot this down", "put this in obsidian", names a
  daily, weekly, monthly or effort note, asks what they were working on or where an investigation
  got to, or wants findings kept somewhere that survives the session.
---

# Obsidian

The vault is where understanding accumulates across sessions. Issue trackers hold *what the team is
doing*; the vault holds *what the user has worked out* — and links out to the systems of record
rather than copying them. Keep that division or the vault turns into a worse copy of the tracker.

## Resolve the vault first

Several vaults sit under one root, and only one is the work vault. Never guess by name — resolve by
structure, because the work vault is the one with an `Effort` folder:

```bash
OBSIDIAN_ROOT=~/Library/CloudStorage/Dropbox/Apps/Obsidian
VAULT=$(find "$OBSIDIAN_ROOT" -maxdepth 2 -type d -name 'Effort*' -exec dirname {} \; | head -1)
```

Other vaults under that root are personal. Don't read them, don't write them, don't mention them.

**Every path has spaces, and most have emoji.** Quote every path, every time. Match folders with a
glob on the leading word (`Calendar*/`, `Effort*/`, `Wiki*/`) rather than typing the emoji — several
carry a trailing variation selector that survives a copy-paste from one terminal and not another, so
a literal match that worked once will silently match nothing later.

## What never goes in

The vault syncs through a consumer file-sync account and has no access control of its own. Treat it
as the least protected place anything lands.

**Never write:** credentials, tokens, API keys, connection strings, encryption keys. A named
individual's personal, financial or health details. Records belonging to a customer's own customers.
Exported rows, dataset dumps, or query output carrying real identifiers.

**Fine to write:** the user's own reasoning. How a system mechanically behaves. `file:line`
references and code shapes. Query *shapes* with the identifiers elided. Links into systems that
enforce their own auth — a link is a pointer, not the data.

The test: if it would need redacting before being pasted into a public gist, it doesn't go in. When a
note needs a specific record to be useful, link to the system of record instead of copying the row
across.

This is forward-looking. Older notes predate the rule and contain things it would forbid — don't go
back and sanitise them unasked, and don't treat their presence as licence.

## The two shapes

**Effort notes** are the hub. One per initiative, at `Effort*/<Name>.md`, holding everything durable
about it. An effort outlives any month, so this is what gets read first and what a session returns
to. Five headings, in this order:

```markdown
## Links
## Mental model
## Open questions
## Decisions
## Working notes
```

`Links` points at the tracker, boards, docs and dashboards. `Mental model` is how the thing actually
works, written so it reads in two minutes. `Open questions` are live and get struck out when
answered. `Decisions` are dated one-liners, newest last. `Working notes` is the dated staging area
where findings land before they earn a place above.

**Period notes** are the journal: terse, dated, and they *link into* efforts rather than restating
them. Three cadences, each designated purely by its ISO prefix:

| Cadence | Name | Folder |
|---|---|---|
| Daily | `YYYY-MM-DD.md` | `Calendar*/Daily notes/` |
| Weekly | `YYYY-Www.md` | `Calendar*/Weekly notes/` |
| Monthly | `YYYY-MM.md`, optionally `YYYY-MM <name>.md` | `Calendar*/Monthly notes/` |

Resolve a period note by globbing its prefix (`2026-10*`), never by exact filename — a monthly note
may carry a trailing name and a daily one may not exist yet.

The promotion discipline is what keeps the hub readable: a finding starts in the daily note, moves to
the effort's `Working notes` once it matters beyond today, and graduates into `Mental model`,
`Open questions` or `Decisions` once it's settled. Don't skip straight to the top; don't leave
everything at the bottom.

## Capture phrases

| What the user says | Where it lands |
|---|---|
| "add this to today", "jot this down", "note this" | today's daily note |
| "add this to this week", "this week's note" | the current weekly note |
| "add this to this month", "add this to my month's obsidian" | the current monthly note |
| "add this to <effort>", "put this in the <X> note" | that effort note, under the fitting heading |
| "put this in obsidian" (unqualified) | today's daily note |

Unqualified capture defaults to the daily note — it's the cheapest thing to get wrong. If an effort
is obviously in play, wikilink it from the daily entry rather than writing to the effort directly.

When asked **what they're working on** or **where something got to**, read in this order and stop
as soon as it's answered: the current monthly note, then the efforts it names, then the last couple
of weeks of dailies. That ordering isn't only about relevance — see below, reading a note can cost a
network round trip, so targeted reads beat sweeping the vault. If a whole-vault search is genuinely
needed, say so first rather than appearing to hang, and don't conclude something isn't there on the
strength of a search that was still materialising files.

## Marking what the agent wrote

So a note never raises "did I write this, or did something go wrong?". The tag is `#agent` and it is
permanent — context, not a workflow. Nothing tracks it, nothing clears it, and no ritual gets built
around it.

**Tag what the agent authored, not what it typed.** Dictated capture is the user's: "add this to
today — the 403 was a backend mismatch" puts *their* words in the note and carries no tag, because
they did write it. The tag belongs on what the agent produced itself — a finding it worked out, a
summary it synthesised, a section it drafted, a note it wrote from scratch.

**One tag per block, never per line.** A tag against each of four bullets is noise, and the reader
stops telling signal from habit. Tag the parent and let the nesting carry it:

```markdown
- Rollover gap — some accounts were never moved to the v2 integration #agent
    - First one: upstream config mismatch, corrected on request
    - Second one: same 403, so it isn't a one-off
```

**A note whose substance the agent wrote** takes it in frontmatter instead — `tags: [agent]` —
rather than scattering it through the body. A period note the agent merely *created* from a template
is a container, not authored content: leave the note untagged and tag the blocks that land in it.

**Never tag the user's own words.** If a confirmed restructure reworks something they wrote, it
stays theirs and stays untagged — marking their own sentence as machine-written is worse than not
marking it at all. Don't retro-tag what's already in the vault.

## Writing

**Append freely. Restructure only on confirmation.** Adding a bullet under an existing heading,
creating a period note that doesn't exist yet, adding a link — just do it. Reordering, rewriting,
merging, renaming or deleting — show what changes and wait. There is no `git` in the vault and no
undo beyond Obsidian's own file-recovery snapshots.

- **Match the register.** Daily notes are clipped bullets and the odd `#jot` tag, not prose. An entry
  that reads like a report in a note full of fragments is wrong even when its content is right.
- **Link rather than restate.** `[[Effort name]]` beats re-explaining it. Before coining a new note
  name, list the vault — a wikilink to a note that doesn't exist yet is a fine marker of something
  worth writing, but two notes that nearly share a name is rot.
- **Use the template** when creating a period note and `Templates/` has one for that cadence; keep
  its headings even where they stay empty, because they're what later appends resolve against.
- **Write a note in one pass,** not a sequence of small appends. See below.

Obsidian-flavoured syntax — wikilinks, embeds, callouts, properties — is covered by the
**`obsidian-markdown`** skill; `.base` view files by **`obsidian-bases`**. Reach for those rather
than guessing at syntax.

## Sync hazards

The vault lives in a file-sync folder, which fails in ways a local directory doesn't.

- **Most notes may be online-only placeholders.** They have a real size but no blocks allocated;
  reading one pulls it down over the network, and a vault-wide `grep` materialises everything it
  touches, one round trip at a time. Count them before assuming a sweep is cheap:
  ```bash
  find "$VAULT" -name '*.md' -print0 | xargs -0 stat -c '%s %b' | awk '$1>0 && $2==0' | wc -l
  ```
  If that returns zero the vault is pinned local and sweeps are free. If it's most of the vault,
  prefer targeted reads and warn before anything broad.
- **Never touch `.obsidian/`.** `workspace.json` and each plugin's `data.json` are rewritten on
  almost every interaction, and they are the documented source of conflicted copies. Nothing the
  agent wants is in there.
- **One write per note.** A burst of small appends gives the sync daemon more chances to fork the
  file mid-sequence. Compose the whole change, then write once.
- **One writer at a time.** If another agent session might be writing the same note, don't — the
  sync daemon arbitrates badly and the loser's work is silently moved into a conflicted copy.
- **Sweep after writing**, and report rather than delete:
  ```bash
  find "$VAULT" -name '*conflicted copy*'
  ```
- **A note open and unsaved in Obsidian can overwrite your write.** For anything substantial, say so
  before writing so the user can close the note.
- **Never `git init` the vault.** `.git` churn against a sync daemon is the worst available outcome,
  and it buys an undo that file-recovery already provides.
