# CLAUDE.md

## Tests and CI

PRs that Claude opens here are merged once CI is green, so CI is the only check on them. Keep it honest:

- When a test fails, fix the code, not the test. Do not loosen an assertion, delete a test, add a skip, or widen an expected value just to get green.
- If a test really must change (the spec changed, or the test was wrong), put the reason in the PR description, under its own heading, so it is reviewed.
- A bug fix comes with a test that fails before the fix and passes after it.
- Before a refactor, record what the current code outputs (golden files or snapshots) and aim for no difference.
- Do not call a real AI model or other network service in tests: save one response and replay it.

## Corrections

When the owner rejects a fix, add the reason here as a rule. Where possible, also turn it into a test or a lint rule so the mistake cannot come back.

## Other

- Reply to the owner in Japanese.
- Do not force-push from a cloud session. To restart a branch whose PR was already merged, merge the old remote branch into the new one and push normally.
