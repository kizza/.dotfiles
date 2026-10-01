---
summary: The guarantees lens — what the chosen primitive promises, and where the code leans on a promise it has not got.
read_when:
  - Running the guarantees lens
---

# Guarantees

Every primitive a change reaches for — a collection, a column, a query, a transaction, a job — carries a set
of promises, and withholds others. This lens looks for the place where the code depends on a promise that
was never made.

This is not bug-hunting. A bug is code that is wrong now. What you are looking for is code that is **right
by accident**: an order that holds because the rows happen to come back that way, a uniqueness that holds
because nothing has raced yet, a rounding that is exact because the test data was small. It passes review,
it passes CI, and it fails in production a quarter later under different data. It is the single highest
yield of any review lens, because nothing else in the toolchain is looking for it.

For each finding, name **the promise relied on**, **the promise actually held**, and **the conditions that
separate them**. A finding without those three is a guess.

## Ordering

- A query whose results are consumed in order without `ORDER BY`. Postgres makes no promise; a plan change,
  an index-only scan or a vacuum silently changes the answer.
- `ORDER BY` on a non-unique column with no tiebreak, then paginated. Rows repeat and rows vanish between
  pages. The tiebreak is the primary key.
- Relying on hash insertion order, `Set` iteration order, or the order a `group_by` yields.
- Order established in one place and assumed in another, with a boundary between them — a job, a serialiser,
  a cache — that does not carry it.

## Identity and uniqueness

- An array where membership is tested repeatedly: the wrong primitive, and quadratic besides.
- A `Set` or a hash key holding objects that define `==` but not `eql?` and `hash`, or neither. Deduplication
  silently does nothing.
- Uniqueness enforced only in the application — a `validates_uniqueness_of`, a `find_or_create_by`, a
  check-then-insert — with no unique index underneath. Two requests is all it takes.
- `first`/`last`/`find_by` where more than one row can match and the choice between them matters.

## Nullability and cardinality

- A column made nullable, or left nullable, where every consumer assumes a value.
- An association declared `has_one` that the data permits to be many, or vice versa.
- A new column added without a backfill, so existing rows carry `NULL` through code that has never seen it.
- Optional made required, or required made optional, without the callers being walked.
- Empty collections through a path that only makes sense non-empty — `max`, `first`, division by `count`.

## Time

- `Date` where `Time` is meant, or the reverse. Truncation is silent.
- A time zone assumed rather than stated. `Time.now` versus `Time.current`, storage versus display, the
  boundary of "today" for a user who is not in the server's zone.
- Ranges whose end inclusivity is not stated or not consistent — `..` against `...`, `BETWEEN` against `<`.
  Off-by-one at a period boundary is a reporting defect that nobody notices for months.
- Precision lost across a boundary: sub-second in Ruby, whole seconds in the column, or the reverse.
- Durations derived by arithmetic on days where a calendar month or a DST transition makes the arithmetic
  wrong.

## Numbers and money

- Float or `double precision` anywhere money, rates or totals live. `decimal` with a stated scale, or
  integer minor units.
- Rounding applied at a different point from where it was before, or applied more than once. Where a total
  is rounded relative to where its parts are decides whether the sum reconciles.
- Scale or precision narrowed by a migration, silently truncating.
- Integer division where a fraction was meant.

## Transactions, locks and concurrency

- Read-then-write with no lock and no unique constraint, where two processes can interleave.
- A transaction whose scope does not cover everything that must succeed or fail together — or one that
  covers an HTTP call, a job enqueue or a mail delivery, which will not roll back.
- Work enqueued inside a transaction: the job can start before the commit lands and find nothing.
- `after_commit` versus `after_save`, and which one the change actually needs.
- Lock ordering that differs between two paths — the deadlock is not visible in either one alone.

## Queries and indexes

- A query shape with no index to serve it, or one whose leading column the predicate does not use.
- A query added inside a loop or a serialiser — N+1 — or an eager load dropped so an existing one returns.
- An unscoped load where the collection grows without bound. `find_each` against `each`, `pluck` against
  loading records.
- Tenant, account or organisation scoping missing from a new query path.
- A migration that takes a lock incompatible with the table's traffic, or that is not backward compatible
  with the code currently deployed.

## Types, enums and encoding

- A string where a constrained set is meant, or an enum extended without its consumers — the `case` with no
  `else`, the exhaustive-looking conditional that is no longer exhaustive.
- Enum values reordered or renumbered, where the integer is what is stored.
- Comparison of values that will not compare: a string against a symbol, a `BigDecimal` against a float, a
  boolean column against a truthy string.
- Encoding or collation assumed — case sensitivity in a `WHERE`, sort order across locales.

## Serialisation boundaries

Every boundary is a place where a guarantee can be dropped, because what comes back is not what went in.

- A job argument, a cache entry or an API payload carrying something that does not survive the round trip:
  a symbol returning as a string, a `BigDecimal` as a float, a `Time` as a string, a record as a stale copy.
- A job taking a record rather than an identifier, so it runs against a snapshot.
- A cache key that does not include everything the cached value depends on — the stale read is the finding.
- A schema changed on one side of a queue or an API without the other side, where both are deployed
  separately and old messages are still in flight.

## Do not flag

- The absence of a guarantee that nothing depends on. An unordered query whose result is counted is fine.
- Pre-existing shape the change did not touch, unless the change is what makes it load-bearing — and then
  the finding is about the change.
- Performance with no mechanism behind it. "This might be slow" is not a finding; "this runs one query per
  row of an unbounded collection" is.
- Framework behaviour that already provides the guarantee. Check before flagging: Rails supplies a good deal
  of this, and flagging what the framework handles is how a lens loses its reader.

## Severity

- **Critical** — data loss, corruption, or money wrong. Missing unique constraint on a real race; float
  money; a migration that breaks the running deployment.
- **Major** — behaviour wrong under conditions that will occur. Unstable pagination; a boundary off by one;
  a job that races its own transaction.
- **Minor** — a guarantee relied on that happens to hold, with no current path to breaking it. Worth a
  remark, because the next change is what breaks it.
