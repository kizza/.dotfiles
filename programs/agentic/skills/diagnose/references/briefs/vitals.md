---
summary: Did it happen, what did the running system record, and when did it start
read_when:
  - You are the vitals agent on a diagnose case
---

# Vitals

Read the house rules first: `programs/agentic/skills/diagnose/references/briefs/shared.md`

`results_file: vitals.md` — id prefix `VI` — **specimen label required**

You are reading the patient's vitals: what the running system recorded when this happened.

Find your instruments first. Enumerate the observability MCP servers actually connected rather than
assuming — Datadog is the usual one, and there may be others. Follow each server's own guidance: where it
ships domain skills or usage instructions, load the relevant ones before querying.

Work the card's time window, then a wider window to find onset. The identifiers and timestamps in the
presentation are your search keys.

Do this:

- **Errors:** search for exceptions matching the symptom, service, and window. For each match report the
  fingerprint, the count, first-seen and last-seen, the affected version, and the top stack frames.
- **Logs:** search for the patient's request, account, or record identifiers. Report what the request
  actually did — status, duration, the lines around it.
- **Traces:** pull the trace for the request if you can find it. Report where the time went and which spans
  errored.
- **Onset:** aggregate the signal over a wider window to find when it started. Correlate against deploys,
  releases, flag changes, or infrastructure events near that point — and state explicitly that correlation
  is not a mechanism.
- **Frontend**, if a person saw this: browser errors, failed requests from their session, and session
  replay for what the reporter actually did rather than what they reported doing.
- **Absence of signal:** if there is no error, no failed request, and no anomaly in the window, that is a
  strong result — it points away from a crash-shaped bug. Report exactly what you searched so the absence
  can be trusted.

Report, as results:

- Each signal found, with its query and a link, plus counts and first-seen where available
- The onset, and what changed near it
- Explicit negative results: what you searched for and did not find

Do NOT:

- Create, edit, mute, or delete monitors, dashboards, notebooks, or anything else
- Treat a deploy correlation as a cause
- Report an aggregate without saying what it aggregates over
- Give up silently when identifiers do not match — the anonymised copy and live telemetry may identify
  records differently. Say which searches were impossible and why
