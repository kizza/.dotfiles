---
name: wireframe
description: >
  Build a change at planning altitude — every artefact it will touch created in its right place
  with its real names and signatures, and almost none of the guts. Breadth-complete and
  depth-shallow: an impact graph that can be read in two minutes and argued with cheaply, before
  anything gets built out. Fires on "wireframe this", "sketch it out", "footholds only", "don't
  build it yet", and is offered on changes that turn out to span many artefacts. Also worth
  reading when you encounter code that looks deliberately unfinished — signatures with one-line
  comments and `raise NotImplementedError` spread across several files is an approved wireframe,
  not an abandoned stub.
---

# Wireframe

## The outcome everything serves

**He must be able to see the whole arc and spread of a change in a couple of minutes, and disagree
with it cheaply.** Not whether it works — whether it is the right shape, in the right places, cut
along the right lines.

The conversation this exists to produce sounds like: *"hang on, that view is doing too much — make
it a component"*, *"why does that live on the model?"*, *"you've missed the export path"*. Those
come from seeing the **spread**, not from reading implementations. So a wireframe is deliberately
wide and deliberately thin.

Think pair programming with another senior engineer, jumping round the codebase together: *a class
here with this interface, a method on that class that does blah.* Footholds, named well, in the
right files. Nothing more.

It is not a plan in prose, and it is not scaffolded nonsense. The thinking is done to full depth;
only the writing is short.

## Breadth-complete, depth-shallow

That is the whole rule. The two halves pull against each other on purpose.

**Breadth — go the full hog.** Every artefact the finished change would touch gets created or
edited: model, service, job, controller, route, policy, component, template, locale entry, spec
file. Missing one defeats the point. The impact graph *is* the deliverable, and a graph with a hole
in it is worse than no graph, because it reads as complete.

**Depth — less code is more.** Every line is something to read. A method body is one comment and a
raise unless the body *is* the arc. What each thing does should be obvious from what it is called;
if it isn't, the name is wrong, and noticing that is a finding.

### Written in full

Anything that is a decision, or that must genuinely work for the shape to be real:

| Written in full | Because |
|---|---|
| File path, namespace, class name | where a thing lives is half the design |
| Method names and complete keyword signatures | the interface is what's under review |
| The entry-point body of a new flow | three to six lines, nothing but calls to named steps — this is the arc |
| Authorization policy methods | who may do this is a decision, and a missing method raises anyway |
| Routes, enum values, component slot names | cheap, and each one is a decision |
| Associations — only when the column already exists | see **Schema** below |
| Locale keys, with real short copy | where a key lives is itself a signal |

### One comment and a raise

Anything that is the mechanical consequence of a decision already visible: query bodies,
arithmetic, loop internals, string building, error copy, template markup.

```ruby
def call
  return Result.empty if orphaned_line_items.none?

  ActiveRecord::Base.transaction do
    detach_line_items
    recalculate_invoice_totals
  end
end

private

# Line items still pointing at the superseded invoice
def orphaned_line_items
  raise NotImplementedError
end

# Point each item at the surviving invoice, preserving amounts
def detach_line_items
  raise NotImplementedError
end
```

`call` is the only body with code in it, it is five lines, and it is the plan. Everything under it
is a name and a sentence.

## Specs

Real file, real path, the full `describe`/`context` tree, and **body-less examples**.

```ruby
# Item still points at the superseded invoice; expect it to move across
# with its amount unchanged
it "re-points orphaned items at the surviving invoice"

it "leaves items already on the surviving invoice untouched"
it "returns empty without opening a transaction when nothing is orphaned"
it "raises when the two invoices belong to different accounts"
```

A body-less example reports **pending**. Two things never to do:

- **Never** `it "..." do` with only a comment inside. An empty block **passes** — a green example
  asserting nothing is a worse lie than a pending one.
- **Never** `xit`. Forget to un-`x` it after build-out and it is silently skipped forever. A
  body-less example goes live the moment someone writes the body.

The scenario list is the most valuable thing in a wireframe to argue about, so name the **full
intended coverage** — every guard, every sad path. `test-clarity`'s *fewer tests, not more* still
governs: name what you would actually write, never padding.

No `let`s, no factory setup, no assertions. Declaring structures for code that does not exist yet
is guts, and a comment above the example carries the same information in one line.

## Schema — name it, don't write it

**Never generate a migration.** `rails_helper` calls `maintain_test_schema!`, so a migration file
sitting unrun raises `PendingMigrationError` and takes the **entire** suite down — including the
specs the wireframe just wrote. Generating *and running* it instead mutates the dev and test
databases for a change that may well be discarded, leaving an orphan migration and schema drift to
back out.

So name what is needed, where the code needs it, and repeat it in the hand-back:

```ruby
# Wireframe: needs invoices.detached_at (nullable), index on (invoice_id, state)
```

**This is why associations are conditional.** `belongs_to :invoice, optional: true` against a
missing `invoice_id` takes down every spec that loads the model. Declare an association in full
when its column already exists; name it alongside the columns when it does not.

## Red is fine — unknown red is not

Wireframing usually means editing existing code: a new call site, a changed signature. Make that
edit for real. The true call site is half of what's being reviewed, and faking it with a dead
branch hides the integration shape that was the point.

Then **run the specs covering every file touched** — only those files, never whole directories —
and report the failures split two ways:

- **Expected** — the shape changed and the guts aren't there yet.
- **Unexpected** — look at this; it may be a regression the wireframe introduced.

Never hand back red that hasn't been run and named.

**Everything lints.** Run the project's linters over the touched files and leave them clean. A
wireframe that doesn't lint is not a foothold, it's a mess.

## Every symbol must be real

This is the line between a wireframe and scaffolded nonsense, and it is not negotiable.

**The investigation is undiminished.** Trace the data flow, read the real call sites, check the
blast radius across models, services, controllers, jobs, policies and background queues —
everything a real implementation would do first.

Then: every existing class, method, association, column, factory, policy or locale scope the
wireframe names has been **verified to exist**. Anything that does not exist is **deliberately
new**, and appears as a created artefact. Never invent a method on an existing class because the
name sounds right.

## What it leaves behind

**A dirty working tree**, by default. `git diff` is the review surface, and uncommitted is honest —
this isn't work yet.

Offer WIP commits when the change is large enough that the arc benefits from being staged:
introduce the new things, then how they come together. Mark them `WIP` in the subject line; they
get folded away before review (see `commit`, `cherry-rebase`).

No notes file, no PRD, no marker file. A wireframe joins the signal that already exists — the card,
the conversation, `prd.md` if the worktree has one. Nothing new to keep honest.

**One breadcrumb per new flow**, so a cold reader knows the hollowness was approved rather than
abandoned:

```ruby
# Wireframed — footholds only, guts to come
```

At the entry point, once. Not on every hollow method. The shape is its own signal, and this skill's
description carries the rest.

## Build-out

A normal turn. There is no brief to write because the to-do list is derivable from the tree:

```bash
git diff | grep -n NotImplementedError    # the hollow bodies
rspec <the touched spec files>            # the pending examples
grep -rn "Wireframe:"                     # schema and template notes
```

**Done** = none of those remain, the named migration is written and run, and the suite is green.

Redlines from the discussion land as a **revised wireframe**, never as notes. The agreement then
lives in the code and cannot drift from it.

## When it fires

- **Asked for** — `/wireframe`, "wireframe this", "sketch it out", "footholds only", "don't build
  it yet".
- **Offered** when a normal build request turns out to span many artefacts or several subsystems.
  Stop before writing, say where it lands, and wait for an answer. Never assume: asking for a
  feature and receiving a hollow shell is far worse than the reverse.
- **Declined** when the change is one file and trivially small. Say so, and just build it.

If two readings of the request would produce genuinely different landscapes, ask first. Otherwise
pick one, wireframe it, and name the alternative in the hand-back.

## The hand-back

Short, and in this order:

1. **The arc** — one to three sentences, or a few bullets: the thinking, and how the pieces come
   together.
2. **The files** — git-style, with one line of purpose each.
3. **Schema** — what is needed and unwritten, if anything.
4. **Red** — expected versus unexpected, plus the pending count.
5. **Two or three calls to push back on** — the judgement calls that could genuinely have gone the
   other way, put as questions. This is the discussion fuel; without it the reasoning has to be
   reverse-engineered from the diff.

```
Wireframed — detach paid line items before an invoice run cascades its deletes

The run's dependent: :destroy is what takes paid items with it, so the detach has to
happen before the destroy rather than being repaired afterwards. I've put it in its own
service because it opens a transaction, and hung the timestamp off the item rather than
introducing a state machine.

  M  services/regenerate_invoice_run.rb        detach step, before the destroy
  A  services/detach_paid_line_items.rb        the detach itself
  M  models/line_item.rb                       #detach!
  M  policies/invoice_run_policy.rb            who may trigger it
  A  components/detach_confirm_component.rb    confirm dialog + template
  M  config/locales/finance.en.yml             3 keys

  Schema: needs line_items.detached_at (nullable)

  Red: 2 existing examples in regenerate_invoice_run_spec — expected, the destroy
       path changed shape. Nothing unexpected. 7 new examples pending.

  Two calls worth pushing back on:
  • The detach is a service, not a model method — the model method would be one line,
    but it would hide a transaction behind an innocent-looking call.
  • detached_at timestamp rather than a state enum — cheaper, but it cannot express
    "detach was attempted and failed".
```
