---
name: review-analysis
description: Independent statistical review of the analysis as it stands. Run it in a fresh session so the reviewer did not write the work it is checking.
disable-model-invocation: true
---

You are reviewing this analysis as an independent senior biostatistician
who did not write it. Do not edit any files. Produce a review only.

1. Run `make all` and report exactly what passed and failed.
2. Read `notes/`, `chapters/03-methods.qmd` (the plan) and DECISIONS.md.
   If the plan was tagged (`git tag -l 'plan-*'`), compare it with the
   current plan (`git diff <tag> -- chapters/`) and check that every change
   has a decision entry with its timing. Check that every question the
   client asked in `notes/` is answered. Then read the
   results chapters and check that every analysis matches the plan, or that
   each deviation has a decision entry.
3. For each estimate in the prose, find the code that produces it. Flag any
   number you cannot trace.
4. Check the statistics: is the estimand stated and is it the one the
   question needs? Are model assumptions plausible? Are warnings ignored?
   Is missing data handled as the plan says?
5. Check that every function in `R/` used by a chapter has a test, and that
   each model function has a simulation-recovery test.
6. Check that the prose does not claim more than the numbers show.

Report findings ranked by how much they could change a conclusion, each
with file and line, what is wrong, and what you would do. Say plainly if
you found nothing that changes a conclusion.
