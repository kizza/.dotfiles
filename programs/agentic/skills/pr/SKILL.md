---
name: pr
description: >
  Push a branch and create a pull request for the finalised work.
---

Push the branch (--force-with-lease only!) and create a pull request for the finalised work.

# Guidelines:

- Read and use a .github/PULL_REQUEST_TEMPLATE.md if available
  - This template can have sections removed or skipped that are not relevant
  - Delete checklist items that do not apply rather than leaving them unticked. "Tested on staging" goes by
    default — keep it only when the change genuinely needs a staging run before merge
- The "Discussion" context should be a series of bullet points that explain the rationale behind the work, and any noteworthy decisions or trade-offs that were made during development.
  - Less is more! Heavily summarise details to succinct high level details, or specific critical callouts
  - Terse, one or two sentences per bullet point are best
  - More than a dozen bullet points is a smell
- Create the pull request as a DRAFT ONLY

## Description

- **Every code mention is backticked**, as `commit/references/commit-messages.md` has it for a commit body:
  classes, methods, files, flags, spelled as the code spells them.
- **A claim about behaviour links to where it happens.** The link sits under the words that carry the
  claim — the specific behaviour, not the subject or the verb — and points at the declaration that makes
  it true, not a call site. A permalink with the lines selected, so the click lands on the evidence:

  ```markdown
  `SyncClaimJob` resolves invoices [by their identifier alone](https://github.com/<org>/<repo>/blob/<full sha>/app/jobs/sync_claim_job.rb#L41-L47).
  ```

  Keep the link to the fewest words that name the behaviour, usually a short noun phrase and rarely a whole
  clause. When a link spans the sentence, the description reads as a wall of URLs:

  ```markdown
  A line is found by the [reference the client sent](…).     <!-- not: A line is [found by the reference the client sent](…). -->
  ```

  Use the full SHA of the pushed branch head (`git rev-parse HEAD`, after the push), never a branch name,
  so the link survives later commits. Where the reader should see the lines without clicking, put the bare
  permalink on a line of its own beneath the sentence as well — GitHub renders that as an inline snippet,
  and does not for a link under text.

## Output

Open the new draft pull request via the default browser when complete

When the PR carries screenshots for Keiran to upload, open the PR first and then, straight after, reveal the
screenshots in Finder so he can drag them onto the page:

```bash
gh pr view --web
open -R "<worktree>/<first screenshot>.png"   # reveals the folder with that file selected
```

Name the screenshots so they sort together in upload order (`01-…`, `02-…`). Selecting several at once needs
Finder Apple Events, which agent shells are not authorised to send (`-1743`), so `open -R` on the first is the fallback.
