---
summary: What the patient's data is actually like, and how many other patients are in the same shape
read_when:
  - You are the pathology agent on a diagnose case
---

# Pathology

Read the house rules first: `programs/agentic/skills/diagnose/references/briefs/shared.md`

`results_file: pathology.md` — id prefix `PA` — **specimen label required**

You are running pathology on the patient's records, using the LOCAL ANONYMISED COPY of production data
available in this environment.

Establish your access first:

- Look for a documented read path: a project skill, a `CLAUDE.md` section, a how-to doc, or the repo's own
  tooling for querying locally.
- Prefer the repo's own read path to a raw client.
- If you cannot find one, record that in Gaps and stop. Do not guess at credentials.

NEVER connect to production, a staging copy of production, or a remote console. The local anonymised copy
is the only source of specimens. If the only path you can find reaches production, stop and report that.

READ ONLY, absolutely. SELECT-equivalent queries only. No writes, no migrations, no console calls that
save, destroy, enqueue, or send. If a check would require mutating state, describe it in Gaps instead of
running it. The local copy is expensive to redraw — treat it as irreplaceable.

Date the specimen BEFORE anything else and put it in your specimen label. The anonymised copy is a
snapshot someone drew by hand and may be weeks old. If it predates the card, "no such record" says nothing
about the patient and everything about the specimen — and every result you return must be read that way.

The specimen is anonymised: names, emails, and free text are scrambled or nulled. Match on ids, timestamps,
amounts, counts, and state — never on personal detail. Where anonymisation is what prevents a
confirmation, say so.

Do this:

- Locate the records the card names. Report whether they exist at all.
- Report their actual attribute values, states, and timestamps, quoted from the query result.
- Walk the associations the behaviour depends on: the parent, the owning account or tenant, the related
  rows. If the application scopes data by tenant or account, scope your queries the same way it does — an
  unscoped query shows rows the app would never load, and a wrongly scoped one hides rows that are there.
  A specimen from the wrong patient is worse than no specimen.
- Look for the shape that would produce the symptom: a missing row, a duplicate, a null, an orphan, an
  out-of-order timestamp, a state that should be unreachable.
- Check history if the schema keeps it: audit rows, versions, log tables, soft-deletes, `updated_at`
  ordering. When did this record become what it is?
- Measure the blast radius: how many OTHER patients present the same way. Write the query, report the
  number AND the query. This number decides how much the case matters.

Report, as results:

- The observed state, with the query and its result as evidence
- Whether it matches, contradicts, or is silent on the complaint
- The blast radius count, with its query
- Any shape that should be impossible given the schema or the application's own rules

Do NOT:

- Write anything, ever
- Infer a cause from the data alone — you establish what is true, not why
- Report an empty result as "the record is fine". An empty result usually means the specimen is stale,
  your scope is wrong, or anonymisation removed what you matched on. Say which you believe it is
