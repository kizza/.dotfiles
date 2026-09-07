---
name: test-clarity
description: >
  The house standard for writing tests that can be reviewed: each example a self-contained
  story, preconditions stated rather than produced, arrange/act/assert separated, comments
  only where they earn it, fewer tests not more. Language-agnostic principles — applies to
  RSpec, Jest, pytest, or anything else. Use BEFORE writing or editing any test file, not
  only when asked to clean one up; and whenever a test's setup reads as arcane or verbose,
  has "no story", or a test diff is being reviewed for clarity.
---

# Test clarity

## The outcome everything serves

**A reviewer must be able to judge whether the scenario is correct and complete from one
screen** — without resolving setup declared above the example, and without opening a helper
defined elsewhere.

That is the tie-breaker. Where two principles below pull against each other, ask what the
reviewer needs to see, not what the runtime needs to pass. Functional necessity is not the
test; evidence is.

The failure mode this exists to correct: a long slab of hoisted setup, then one small
assertion at the bottom. There is no story. It isn't reviewable, so it isn't scalable.

## The shape

    scenario name, in the domain's words
      one behaviour, named as behaviour

        arrange   a handful of lines that say what had happened
                  a trailing note on the one or two that need it
        (blank)
        act       the single call under test
        (blank)
        assert    the one thing the name promised

If arrange is outgrowing assert, the scenario is too big. Split it, or find the named state
the fixture layer already provides.

## Self-containment

- **Each example readable in and of itself.** This is the priority the others yield to.
  Repeating two lines of setup across three examples is cheaper than one shared declaration
  the reader has to go hunting for.

- **Share setup only when every example in the group needs it, and only when it is one
  simple thing.** Never a chain of shared declarations each depending on the last — that
  hoists the story out of the examples and leaves them meaningless alone.

- **Don't extract helpers.** Least of all for a single call site. A helper earns its place
  only when it serves several examples *and* hides mechanics that would otherwise mislead —
  the low-level escape hatches used to force state that the normal path forbids. When one
  earns it, define it *below* the examples it serves, so the reader meets the story first.

- **One group per theme, one case per scenario, one assertion subject per case.** Name groups
  after the behaviour, in domain language, not after the method being called. Fold a
  near-duplicate group into the existing one rather than tacking another onto the file.

## Preconditions

- **State the precondition; don't produce it.** Setup that runs a service, job, or workflow to
  arrive at a starting state is a smell. Ask what state it produces, then assert that state
  into existence directly. Keep the call only when the thing under test *is* that service.

- **Before writing state by hand, check whether the fixture layer already names it.** A named
  state usually exists and usually means more than the attributes it sets — the domain
  vocabulary is already there. Several hand-written lines commonly collapse into one name.

- **Pass only what the behaviour depends on.** Let defaults carry the rest. Specific values
  only where the value itself is the point. Drop associations and attributes the fixture or
  the parent record already implies.

- **But keep what substantiates the comment above it.** An attribute can be functionally
  unnecessary and still earn its place as the observable residue of the situation being
  described. This is where minimal setup and storytelling collide: resolve it by asking
  whether the reviewer needs it as evidence, or whether it merely accompanies the rest.

- **Name a value for the parameter it feeds**, so the assignment can be carried by whatever
  shorthand the language offers rather than restated.

## Time and derived values

- **Anchor time to a literal, then derive periods with the language's calendar vocabulary.**
  A literal date plus a named period reads as a calendar. Setup computed from "now" makes the
  reader simulate a clock, and imports a timezone sensitivity that then has to be defended
  with extra runs.

- **Derive later values from earlier ones, and state the relationship.** Expressing the second
  period in terms of the first says how they relate. Recomputing both from a common origin
  makes the reader do arithmetic and verify they abut.

- **Prefer the concrete named operation over intermediate variables.** Locals that exist only
  to make the mechanics work are things the reader must hold; a named operation on the value
  states intent in place.

- **Walk a chain by recursion, not by reassigning a local in a loop.**

## Assertions

- **Assert the one thing the name promised**, using the most expressive form available —
  a before/after change, an attribute set, an unordered collection match — rather than
  capturing values into locals and comparing them by hand.

- **Put a safety assertion where the dangerous operation is.** A guarantee that nothing was
  destroyed belongs inside the example that triggers the destruction. Asserted in its own
  example, away from the risk it guards, it is decoration.

## Comments

Comment craft is global — see the `## Comments` rules in the global instructions. Two things are
specific to tests:

- **Label the setup off to the right.** A few words trailing a setup line, giving it the domain
  meaning its syntax can't carry: what this record *means* in the story, not what the call does.
- **Only the lines that need it** — two of four, not four of four. Where the line already reads as
  domain truth, a note on it is a second voice saying the same thing.

## Restraint

- **Fewer tests, not more.** No test for a mechanical migration. No case re-asserting what the
  case above already proved about a sibling attribute — one instance is sufficient. A change
  that is one guard clause needs one or two examples, not a suite.

## When something won't fit, diagnose the surroundings

- **When a natural idiom "doesn't work", suspect the machinery, not the idiom.** An idiom that
  won't fit is usually diagnosing the code around it — a lossy conversion, a boundary the
  design shouldn't have. Reach for the awkward explicit form only after ruling that out;
  often the right fix is upstream of the test.

- **Setup that changes nothing is lying.** If removing a piece of setup leaves every example
  passing, it was never load-bearing. Delete it, and rewrite the comment to describe what
  actually makes the scenario arise — which is often not what the comment claimed.

- **Fix the test, not the system.** If a failure can only occur at test speeds — two calls
  landing in the same instant — simulate reality in the test and leave the system alone.

## Where the tier changes the means

The outcome never changes; at the outermost tier the means invert.

- **Unit, model, service, component:** the setup floor is near zero. Inline everything. A
  helper for one call site is pure noise.
- **End-to-end, system, browser, request:** the setup floor is irreducible — an authenticated
  actor, a tenant, navigation. Here *one well-named helper per journey step* is precisely what
  buys the one-screen read, and refusing to extract it destroys the outcome in the name of the
  rule. Everything else still holds: arrange/act/assert, comment discipline, domain naming,
  fewer cases.

Judge which tier you are in before applying the helper rule.

## The pass

1. **Scope it.** The test files in the diff, or the files named. Nothing else.
2. **Read the subject under test, and the fixture layer it draws on** — so names can state
   domain truth, and so existing named states get used instead of hand-written ones.
3. **Rewrite case by case.** Coverage must stay equal or improve. Where a case is genuinely
   redundant, or setup proves not load-bearing, remove it and say which and why — never
   narrow coverage silently.
4. **Run exactly those test files**, then the linters. Never a whole directory: a broad run
   costs many minutes and buys nothing the diff hadn't already told you.
5. **Report** what shrank, which shared declarations and helpers dissolved, which produced
   preconditions became stated ones, anything intentionally dropped, and any place the
   principles pulled against each other so the call was a judgement.

If the language has no established convention for one of these, apply the principle, choose
the idiomatic local equivalent, and name the choice in your report.

Keep the test in the same commit as the change it covers.
