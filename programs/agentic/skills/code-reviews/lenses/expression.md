---
summary: The expression lens — how the code reads. Naming, comments, simplicity, test clarity.
read_when:
  - Running the expression lens
---

# Expression

You are reading this code for the first time, with no knowledge of why any decision was made. Your job is
to name what would confuse, mislead or slow down the next person to open the file — and nothing else.

The rubric is `~/.claude/CLAUDE.md`, plus any `CLAUDE.md` covering the changed paths. Quote the rule you are
applying. A finding that cannot cite a rule or point at established code nearby is a preference, and
preferences are not findings.

## Naming

- A name that does not say what the thing is. The standard here is spelled-out over terse:
  `subscription_provider_identifier`, not `sp_identifier`; `membership_commenced_on`, not `commenced_on`.
- An abbreviated alias coined only to shorten a call site.
- A local or a `let` named differently from the attribute or keyword it feeds, where matching the name
  would let shorthand assignment carry it — `create(:x, account_owner_id:)` over
  `create(:x, account_owner_id: account_owner_id)`.
- A name that suggests one thing and does another. This is the severe case: misleading beats unclear.
- Deviation from a naming pattern the same file or module already establishes. Cite the existing code.

## Comments

Judge against the `## Comments` rules. A comment earns its place by carrying what the code cannot.

- **Preamble.** The point is not in the first few words.
- **Restating the code.** A note narrating what the next line plainly does, or repeating the signature.
- **One on every line.** Four consecutive annotated lines is noise — the reader stops telling signal from
  habit. Flag the block, not each line, and say which one or two deserve to survive.
- **Narrow and fragmented.** Wrapped short where 120 columns would have carried it in fewer, denser lines.
- **Stale.** The comment no longer describes what happens. The code is the truth: it gets rewritten or
  removed. This is the most severe comment finding and it is always worth a remark.

## Simplicity and flow

- Something simple done in a complicated way. Say what the simpler shape is.
- Nesting that a guard clause or an early return would flatten. Inverted conditions that read backwards.
- A ternary that chooses between two paths rather than two values — a call in each arm, or a line the
  reader has to parse to see which branch runs. Judge against `## Control flow`: the special case returns
  early and the common one falls through.
- Missing context — code that cannot be understood without knowledge absent from the file.
- Dead code introduced by this change: unreachable branches, unused locals, commented-out code.
- Duplication of logic that already exists elsewhere in the codebase. Point at the existing one.

## Tests

If the change touches a test file, read the `test-clarity` skill (`~/.claude/skills/test-clarity/SKILL.md`)
and judge against it. A reviewer must be able to take the scenario from one screen.

- An example that cannot be read alone — setup hoisted above it, or a helper it makes the reader chase.
- Setup that reaches a state by running the system under test, where it could assert the state into being.
- State written by hand that the fixture layer already names.
- Time computed from `now`, where a literal anchor and a named period would read as a calendar.
- A comment on every setup line, or setup that turns out not to be load-bearing.
- A safety assertion in an example of its own, away from the operation it guards.
- More tests where fewer would say it.

**The tier rule inverts this at the end-to-end level**: there a named helper is what buys the one-screen
read, so flag its *absence* on an irreducible journey step, not its presence.

## Do not flag

- Complexity the problem genuinely carries. Necessary is not the same as accidental.
- Well-known standard library or framework idiom.
- Taste where the rules are silent — you would have written it differently and both are fine.
- Anything a formatter or linter handles.
- Readability problems on lines this change did not touch.
- Missing tests or missing error handling. That is the spec lens, or it is an opinion.

## Severity

- **Major** — actively misleading. A stale comment, a name that lies, a test whose scenario cannot be read.
- **Minor** — unclear but decipherable with effort. Most naming and structure findings land here.
- **Nitpick** — a preference with a rule behind it. Worth a remark only if it is quick and unambiguous.
