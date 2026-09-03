---
summary: How a result is known and how it is written down — tiers, confidence, the result block, the specimen label, the impression
read_when:
  - Running any test — this is the output contract
  - Grading or filing a test's results into the differential
---

# Evidence

Read by every test (it is how you report) and by the attending (it is how results are weighed). Small on
purpose: it is loaded once per agent, on every case.

## Evidence Tiers

Every result is labelled with how it is known.

| Tier | What it means | Examples |
|---|---|---|
| **observed** | Seen in this patient, in a system of record | A query result showing their record's actual state; the trace of their actual request; a session replay of the click; a provocation that fired |
| **population** | Many cases summarised, so this patient's case is inferred | An error count over a window; "37 patients present the same way"; an onset chart; a p95 |
| **structural** | Traced in the code, not observed running | "This guard returns early for suspended accounts, which produces the blank page" |
| **circumstantial** | Reasoned from pattern, precedent, or absence | "It started at the deploy, so probably that change"; "a similar card last month concluded X" |

**Tiers beat each other.** When two results conflict, the higher tier wins and the differential records why
the lower one misled. Structural reasoning that contradicts a query result is wrong structural reasoning —
usually a path the code does not take, a flag that is off, or a second writer to the same column.

A candidate supported only by `structural` results is a **hypothesis**. It cannot close the differential on
its own: promote it by confirming one link at `observed` or `population` tier, or carry it into the write-up
explicitly labelled unconfirmed.

## Confidence

Each test scores its own results.

| Score | Meaning | Action |
|---|---|---|
| **0** | Not a result. Speculation, or already known and irrelevant. | Do not report |
| **25** | Weak. A direction, not an observation. Could not be checked. | Do not report |
| **50** | Moderate. A real observation whose bearing on the complaint is unclear. | Report only if it fills a known gap |
| **60** | Relevant. Verified, and plausibly bears on the complaint. | Report (at threshold) |
| **75** | Strong. Verified, and clearly supports or contradicts the complaint. | Report |
| **90** | Very strong. Directly explains or directly refutes the complaint. | Report |
| **100** | Conclusive. Settles the question on its own. | Report |

**Threshold 60.** Below that it does not reach the differential.

Four things score **0** however true they feel. Do not report them:

- A correlation with no mechanism — "it started at the deploy" locates a change, it does not explain a symptom
- A mechanism nobody traced — "probably caching", with no file:line and no observation
- The reporter's own theory, repeated back — the card usually contains a diagnosis, and it is a claim to test
- A restatement of the complaint — "the total is wrong" is not a finding when it is the presenting complaint

The attending may **drop or downgrade** a result, and may **upgrade** one that two tests found
independently. It never invents a score a test did not give, and never changes a tier — only the test that
observed something can say how it was observed.

## The Result Block

Every result gets an id: the test's prefix plus a number — `TR` triage, `IM` imaging, `PA` pathology,
`VI` vitals, `CH` chart review, `PV` provocation. Ids are permanent; the differential refers to results by
id alone.

```
### IM1 — guard skips suspended accounts
finding:    The invoice builder returns early for suspended accounts, omitting the line.
evidence:   app/.../invoice_builder.rb:112-118 — `return if account.suspended?` before the line is appended
tier:       structural
confidence: 75
bearing:    supports
```

`bearing` is one of `supports`, `contradicts`, or `bounds` — where `bounds` sizes the problem (a blast
radius count, a time window) without arguing for or against a mechanism.

The file ends with:

```
## Gaps
- What could not be checked, and what access would be needed to check it.
```

## The Specimen Label

**Required at the top of `pathology.md` and `vitals.md`.** No exceptions.

```
## SPECIMEN
drawn from: local anonymised copy | instrumentation MCP (<name>)
via:        <the exact read path used>
drawn on:   <snapshot date or data window, and how it compares to the card's date>
written:    nothing
```

The attending **rejects a results file that needs a label and has none**, and re-orders the test.
If `drawn from` names production, or anything that reaches it, the attending **aborts the case** and tells
the human.

`drawn on` exists because the anonymised copy is a specimen someone drew by hand and may be weeks old. If it
predates the card, "no such record" says nothing about the patient and everything about the specimen — and
every result from that file has to be read in that light.

## The Impression

A test returns roughly fifteen lines and nothing more. The detail stays in the file.

```
SPECIMEN: local anonymised copy | drawn 2026-08-19 | PREDATES card (2026-09-01) | written: nothing

| id  | finding                              | tier     | conf | bearing  |
|-----|--------------------------------------|----------|------|----------|
| PA1 | invoice 4471 has no line for the fee | observed | 95   | supports |
| PA2 | account suspended 3 days prior       | observed | 90   | supports |
| PA3 | 37 invoices in the same shape        | pop.     | 80   | bounds   |

GAPS: no version rows for invoices in this specimen — could not check when it changed.
```
