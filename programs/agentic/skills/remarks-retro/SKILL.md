---
name: remarks-retro
description: >
  Mine the remarks archive — every review comment ever resolved, across every repository, held as
  monthly JSONL under `${XDG_DATA_HOME:-~/.local/share}/remarks/` — for what it says about how
  you want code written, and turn that into edits to `CLAUDE.md`, to skills, and to the house
  standards. Use when asked what the remarks say, what to fold back into the agent instructions, or
  for a retro over a month or a quarter of review.
---

# Remarks retro

**Placeholder.** The archive is being written; this is not yet written. Flesh it out once there is
a month of data to point it at.

## What is there to work with

`${XDG_DATA_HOME:-~/.local/share}/remarks/<YYYY-MM>.jsonl`, one JSON object per line, append-only,
one file per month. Every remark removed through the `remarks` CLI — that is, every remark an agent
took away because it addressed it. Remarks deleted in the editor never arrive here.

```json
{"id":"0895a2","repository":"invoicing","file":"src/invoice.ts","line":84,"end_line":84,
 "branch":"billing","commit":"7c386a3","created_at":"2026-09-22T12:27:48Z",
 "comment":"Why are we bypassing normalization here?",
 "snapshot":["  const result = calculateInvoice(raw)"]}
```

`comment` is what was said, `snapshot` is the code it was said about. That pairing is the whole
value: an objection with the thing that provoked it, several hundred times over, across every
repository worked on.

## The shape it should take

Read a window. Cluster by what was actually being objected to rather than by repository or file.
Carry the evidence — the same objection made eleven times, each with its snippet, is an argument;
one made once is an anecdote. Then propose the smallest edits that would stop it being said again:
to `~/.claude/CLAUDE.md`, to `test-clarity`, to whichever skill owns that ground.

Propose, with the evidence attached. Do not edit the standards unasked.
