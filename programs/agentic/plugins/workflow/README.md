# Workflow

A small team of Claude roles that takes work from a pile to a pull request, with you deciding only two
things: **which slice to pick up**, and **when to push**. Everything between those runs on its own.

The roles are skills, not agents. Each is a lens over the craft skills that already exist — `commit`,
`pr`, `test-clarity`, `code-reviews`, `remarks`, `triage`, `worktrees` — saying who reads what, what
they produce, and who they hand to. `skills/contract/` is the contract they all read first.

It is packaged as a Claude Code plugin, so the skills are `workflow:manager`, `workflow:product` and so
on — loaded from this directory through `CLAUDE_CODE_PLUGIN_DIRS`, or installed from a marketplace.

## The team

| Role | Runs as | Job |
|---|---|---|
| **manager** | one long-lived session in the `Standup` tmux session, looping every ten minutes | the standup: re-reads the world, moves what is in flight, keeps three slots, tells you what needs you |
| **product** | a read-only subagent the manager forks when a slot is free | reads the piles and proposes three slices that are almost no-brainers |
| **engineer** | one session per slice, in its own worktree and tmux window | brief → build → commits → ready → remarks addressed → PR |
| **reviewer** | a read-only subagent the manager forks when an engineer says ready | reviews the branch against its brief and your own past remarks, as remarks; at most two passes |
| **retro** | on demand, from any session | takes one "this shouldn't happen again" to the one skill it belongs in |

Each is usable alone. `/workflow:engineer` on a card is today's "spin up a worktree and go";
`/workflow:product` is "what should I pick up next?"; `/workflow:retro` is "update the right skill".

## The flow

```
                 pile(s)                 the effort note names them
                   │
            product proposes 3           → vault, Working notes
                   │
   ┌─── you pick one ────────┐            gate 1
   ▼                        │
in flight                   │            worktree + BRIEF.md + engineer window
   │  engineer builds       │
   │  reviewer passes (≤2)  │
   │  "ready for you"       │
   ▼                        │
   you: push ───────────────┘            gate 2
   ▼
in PR                                    draft PR; CI and humans
   │  you leave remarks ──→ back to in flight, engineer addresses, pushes
   ▼
done                                     outcome line written beside the proposal
```

Three in flight at most. The stage says whose hands a slice is in, and that is all the board needs.

## Starting it

```bash
tmux new-session -s Standup -n manager          # once
claude --name manager '/workflow:manager <Effort>'
/loop 10m /workflow:manager <Effort>
```

`<Effort>` names the **effort note** the workflow runs under — `Effort*/<Effort>.md` in the vault. One
initiative is one note and one manager. The manager opens each engineer in its own `Standup` window, in
the worktree, and paddck's sidebar shows them all.

## Where things are

| | |
|---|---|
| the piles, and what "valuable" means this month | the effort note's `Links` and `Mental model` — **yours to write** |
| proposals (declined ones struck through with your reason), picks, outcomes, standup boards | the effort note's `Working notes`, appended by the manager |
| a slice's goal, scope, shape, log | `BRIEF.md` at the worktree root, outside git |
| a slice's stage | a paddck annotation on the worktree path |
| review findings | remarks in the worktree |
| corrections to the mechanics | the skill they belong in, logged in `~/.local/share/remarks/retro.md` |

The manager remembers nothing between ticks on purpose. Kill it and start it again; the vault and
paddck are the state.

## Intervening

- **In a branch:** switch to the engineer's window, or go into the worktree, review the commits, leave
  remarks, and say "address them". Your own edits to the branch are treated as the baseline.
- **In a proposal:** decline with a reason. It is struck through, and product reads the reason next time.
- **In the mechanics:** `/workflow:retro "the engineer keeps …"` from wherever you are. It finds the one
  home, shows the diff, applies on your yes, and leaves a row the monthly `remarks-retro` can mark.

## What it leans on

Craft skills: `commit`, `pr`, `test-clarity`, `code-reviews`, `remarks`, `remarks-retro`, `triage`,
`worktrees`, `worktree-isolation`, `obsidian`, `run`, `cherry-rebase`, and whichever skill owns the
tracker (`basecamp` here). Tools: tmux, `gh`, the `remarks` CLI and its archive, paddck for the sidebar
and annotations, an Obsidian vault with `Effort*/` notes. Swap any of them for your own equivalent; the
contract names what each is for, not how it is built.

## Measuring product

Every slice that reaches *done* gets an outcome line beside the proposal that promised it: commits landed
against commits shaped, review passes, whether it widened, days in flight. Product reads those before
proposing again. A proposal that was a no-brainer lands as shaped in one pass; one that was not shows up
here, and that is what the monthly retro reads.
