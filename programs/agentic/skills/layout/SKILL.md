---
name: layout
description: >
  How Keiran lays out agentic work across tmux — which window, session and pane a thing belongs in,
  with paddck's sidebar alongside — and the arrangements he asks for by name. Use whenever he asks to
  open, place, move, arrange or organise windows, sessions or worktrees around the agent: "open the
  worktree to the right / beside me", "give me a window in that worktree", "take me there", "where
  should this go", or anything about how his workspace is laid out. The agent knows what things are
  for; tmux only knows where they are. This skill is the agent's hand on the arrangement.
---

# Layout

Keiran works in one tmux server, with paddck over the top of it. tmux holds the panes, windows and
sessions; paddck knows what each is *for* — which agent is in which pane, what it was asked, whether
it wants him. The agent sits in a window of its own, and the things it is working on sit near it. Where
they sit is a habit worth keeping, because it is what lets him find them without thinking.

## The picture

- **A session is an effort.** One per piece of work or per repo he has in play; paddck's `prefix m`
  moves a pane between them.
- **A window is a thing.** An agent, a shell in a worktree, an editor, a server. Tabs show the
  directory's basename, or paddck's label for an agent, so a window needs no name of its own.
- **New windows open to the right.** `prefix c` is `new-window -a`, and windows renumber, so
  "to the right of this one" is a stable place rather than an index.
- **The sidebar is not furniture.** Paddck's toolbar is one pane carried between windows, and every
  other window holds an empty slot for it. Panes stamped `@paddck_slot`, and the sidebar itself, are
  never split, resized, killed or moved by the agent.

## Finding yourself

An agent's tools inherit `$TMUX_PANE`, so its own place is one call away and never has to be asked:

```bash
tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_index} #{window_id}'
tmux list-windows -t "$TMUX_PANE" -F '#{window_index} #{window_id} #{pane_current_path}'
```

`$TMUX_PANE` unset means the agent is not in tmux: there is nothing to arrange, so say so and give
the path or the answer in words instead.

## Arrangements

Each is a gesture Keiran asks for by name, with the mechanism that does it. The mechanism is a script
on `PATH` under `~/.dotfiles/bin`, so the skill says *when* and the script says *how*.

### The worktree beside the agent

The worktree the agent is working in lives in the window directly to the right of the agent, where
`M-}` reaches it. The agent knows which worktree that is, so the agent puts it there:

```bash
beside "$WORKTREE_PATH"          # open it to the right; he stays here
beside --go "$WORKTREE_PATH"     # "take me there"
```

`beside` works from `$TMUX_PANE`, opens the window right after the agent's, and prints where it landed
as `session:index`. A window in the session already standing at that path is moved into place rather
than opened twice, so repeating the ask is harmless. It does not select the window — Keiran is still
reading this one — unless `--go` says to.

Which directory, in order: one he named (`~` expanded; a bare `<repo>/<slug>` is
`~/Code/worktrees/<repo>/<slug>`); otherwise the worktree this session created or works in, the
**`worktrees`** skill's `$WORKTREE_PATH`; otherwise `git worktree list` matched against the branch
under discussion. Nothing matching means ask — never open a guess. The directory has to exist, so a
worktree still to be made is created first and opened second. The **`worktrees`** skill does this
itself for a single new worktree.

Report in one line, as the script printed it: *Opened beside this window at lookout:4*. The window is
a plain shell; direnv loads the worktree's env on its own.

## Adding an arrangement

When he describes a new way he wants things placed, it becomes a section here and, where tmux needs
more than one command, a script beside `beside` in `~/.dotfiles/bin`: the agent's own window from
`$TMUX_PANE`, idempotent on a repeat, focus left where it is unless asked to move, and where it landed
on stdout. Never kill a window or pane, and never touch the sidebar or its slots.
