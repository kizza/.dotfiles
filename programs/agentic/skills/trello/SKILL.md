---
name: trello
description: |
  Read and work Trello through the `trello` CLI, a thin client over Trello's REST API: list boards,
  a board's lists and cards, read a card and its comments, comment, move a card between lists or
  boards, create a card. Use for any Trello question or action — "what's on the board", "show me the
  cards in Doing", "move this to Progressed", "what did they say on that card", a trello.com link.
---

# Trello

`trello` is a short script in the dotfiles (`programs/trello/trello.sh`); read it when its output
or an error needs explaining. Run `trello` alone for usage.

## Rules

- **A URL is an id.** Pass a `trello.com/b/…` board or `trello.com/c/…` card URL, its shortlink, or
  an id straight through. Lists are named: case-insensitive, exact or a unique substring. An
  ambiguous name fails and prints the board's lists, so pick from those rather than guessing.
- **Writes are live** — `comment`, `move` and `create` are seen by the whole board, and members are
  notified. Run one only when Keiran asked for that change in this conversation.
- **No credentials in the Keychain** means `trello login` has not been run. It reads 1Password, which
  needs Keiran's fingerprint, so ask him to run `! trello login`. Never run it yourself — it stalls.

## Commands

| Want | Command |
|------|---------|
| My boards | `trello boards` |
| A board's lists | `trello lists <board>` |
| Everything on a board, by list | `trello cards <board>` |
| Cards in one list | `trello cards <board> "<list>"` |
| A card and its comments | `trello card <card>` |
| Comment | `trello comment <card> "<text>"` |
| Move to a list on the same board | `trello move <card> "<list>"` |
| Move to another board | `trello move <card> "<list>" --board <board>` |
| Create a card | `trello create <board> "<list>" "<name>" ["<description>"]` |
| Anything else | `trello api <METHOD> <path> key=value…` — raw JSON |

Output is tab-separated with the shortlink first, so a card from one listing feeds the next command.
`trello api` reaches the rest of the API (labels, members, due dates, checklists); it sends `GET`
pairs as a query and other methods as a form body, e.g.
`trello api PUT /cards/<card> dueComplete=true`.
