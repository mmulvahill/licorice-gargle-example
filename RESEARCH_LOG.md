Append-only. Newest entries at the bottom. What happened, what we learned,
and what it changed. Short is fine. This is a hand-written log, so its
numbers are typed; the report chapters compute theirs.

**2026-10-16** First data delivery: `licorice_gargle.csv`, emailed by the
PI's fellow, the public `medicaldata` version (MD5
`fe23d586f6bdc92a5db1342f8e41a283`). It has 235 rows and 19 columns,
matching the codebook names, and every variable the plan uses is present.
There are no duplicate rows and no patient ID column. Disagreement with
the notes: the codebook says 236 were enrolled, but the file has 235
rows. That is now an open question in Chapter 1 (D-019 covers how the
file is handled).

**2026-10-16** Structure check at receipt. Outcome values were checked
only for validity and missingness, not summarised. The baseline variables
and `treat` have no missing values and contain only codebook codes. All
four planned sore-throat scores are integers from 0 to 10. The same 2
patients are missing every post-operative variable (all cough and pain
columns), which confirms the client's "a couple pts no post-op data".
That is under the 5% revisit trigger in D-015, so complete case plus
bounds stands. Only 2 patients have a preoperative sore throat, so under
the pre-specified rule in D-011 it is left out of the adjusted model. All
other covariate categories in that model have at least 10 patients, so
D-016 merges nothing. Mallampati class 4 has 1 patient, but Mallampati is
not in any model.

**2026-10-16** Cleaning function written (`clean_raw()`,
`assessments_long()` in `R/clean.R`) with known-answer tests on a
hand-built file of 4 patients. Each test was checked by deliberately
breaking the code in three ways: swapped treatment labels, sore throat
defined as `>= 0`, and the whole-number check removed. The tests caught
all three. The real file passes validation (235 patients; 940 rows in the
long table). Two choices the codebook does not settle: `patient_id` is the
raw row number, since the file has no identifier, and age and BMI get
only wide plausibility bounds (age 0 to 120, BMI 10 to 80), because the
codebook gives no range for them.

**2026-10-17** Model functions written in `R/models.R`: per-assessment
logistic regression with risk difference, exchangeable GEE, random-intercept
mixed model, adjusted model with sparse-level merging, and missing-outcome
bounds. The simulator is in `R/simulate.R`, and nothing has been fitted to
the trial data. Each recovery test uses 200 simulated trials of 235
patients, 2 of them without post-operative data. The marginal truths
(per-assessment OR and RD, the GEE's common OR, and the within-patient
correlation) come from integration over the random intercept. The GEE
scenario solves for the licorice intercepts that make the marginal OR
constant (D-018). Two findings:

- Laplace fitting of the mixed model underestimated the patient SD and
  gave a convergence warning on a simulated trial, so the mixed model uses
  9-point quadrature (D-020, proposed).
- 13 deliberate breaks were tried. 12 failed tests at once. The
  independence-GEE break passed every test, because an independence GEE
  gives the same OR and valid sandwich CIs. The GEE now reports its working
  correlation, and the test compares that with the integrated truth.
- 90% CIs were caught only by the GEE and adjusted-model coverage checks,
  so `odds_ratio()` now has an exact CI check.
- After both changes, all 13 breaks fail at least one test.

**2026-10-17** The break harness is now committed as
`scripts/check_test_breaks.R`. D-020 was confirmed by the analyst before
any fit to trial data. The final run, against the final tests, lists for
each break the tests that failed:

- Mixed model swapped for a logistic regression ignoring patients: the
  mixed-model recovery test (bias 0.248 against an allowed 0.08; coverage
  0.525).
- Mixed model by Laplace: the mixed-model recovery test (mean patient SD
  off by 0.128 against an allowed 0.1).
- GEE ignoring patients: the GEE recovery test (coverage 0.83; SE ratio
  0.70; working correlation off by 0.271, i.e. estimated near zero).
- GEE with independence correlation: the GEE recovery test (no working
  correlation).
- Per-time fit pooling the assessments: the `fit_assessment` known
  answers, plus per-assessment recovery (coverage, SE ratio and sample
  size).
- RD sign flipped: the RD known answers and RD recovery.
- RD SE using the total n: the RD known answers, plus RD coverage at one
  assessment.
- 90% CIs: the `odds_ratio` known answers, plus GEE and adjusted coverage.
- Adjusted model without covariates: adjusted recovery (the large-sample
  estimate off by 0.171 against an allowed 0.06).
- Sparse levels never merged: the merge and covariate-rule known answers.
- Bounds labels swapped, or both arms filled the same way: the bounds
  known answers.
- Integration using the variance as the SD: the integration known answers,
  plus per-assessment and GEE recovery.
