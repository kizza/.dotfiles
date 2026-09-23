---
name: remarks
description: >
  Read and address remarks — review comments left against the code in this repository, held in
  `.remarks/` and reached through the `remarks` CLI. Use whenever remarks are named, or when the
  user refers to comments, notes or questions they have left against the code: "address my
  remarks", "what did I leave you", "go through the review". Also use before calling a
  review-driven change finished, to check nothing was left standing.
---

# Remarks

A remark is a review comment against a file and a line of this repository — written in the editor,
read here. They live in `.remarks/`, untracked, one JSON file per source file, and the CLI is the
whole interface: do not read or write `.remarks/` directly.

```bash
remarks list [--file <path>] [--json]     # every outstanding remark
remarks show <id> [--json]                # one remark in full
remarks resolve <id>                      # delete it, by id or unique prefix
remarks add <file>:<line>[-<end>] [text]  # text on stdin if omitted
remarks clear [--file <path>]             # delete every remark
```

A remark exists until it is deleted; there is no other state. `list` is therefore the outstanding
review, and deleting is the only signal its author gets back.

Resolve each remark as you address it, rather than clearing the lot at the end. What is still
standing when you finish is what you did not do, which is the whole point of the protocol — and
everything removed through the CLI is kept, so a remark resolved without being addressed is a lie
that outlives the branch.

## Reading one

`line` is where the remark was written, not where it points now. Take `current_line` from the JSON,
and check `located`: `false` means the recorded source has changed beyond recognition and the line
is only a hint — `snapshot` is the source the author had in front of them, and `comment` is what
they said about it.

`branch`, `commit` and `created_at` record where the work stood at the moment of writing. History
moves underneath a remark, so read them as provenance rather than as coordinates.
