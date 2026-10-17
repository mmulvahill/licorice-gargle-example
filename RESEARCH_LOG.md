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
