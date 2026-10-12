---
name: pr
description: >
  Push a branch and create a pull request for the finalised work.
---

Push the branch (--force-with-lease only!) and create a pull request for the finalised work.

# Guidelines:

- Read and use a .github/PULL_REQUEST_TEMPLATE.md if available
  - This template can have sections removed or skipped that are not relevant
- The "Discussion" context should be a series of bullet points that explain the rationale behind the work, and any noteworthy decisions or trade-offs that were made during development.
  - Less is more! Heavily summarise details to succinct high level details, or specific critical callouts
  - Terse, one or two sentences per bullet point are best
  - More than a dozen bullet points is a smell
- Create the pull request as a DRAFT ONLY

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
