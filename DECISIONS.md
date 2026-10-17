Every decision that could change a result is recorded here, with the
alternatives considered and who made it. Entries are never deleted; a
reversed decision gets a new entry that supersedes the old one. **Timing**
says whether any results had been seen when the decision was made: a change
made after seeing results is post hoc, and is marked as such here and in
the analysis plan. This file is a hand-written log, so its numbers are
typed; the report chapters compute theirs.

## D-001: Primary outcome is any sore throat at rest at PACU 30 min

- **Date:** 2026-10-16
- **Decided by:** PI, confirmed on a call with Matt Mulvahill on
  2026-10-16 (`notes/2026-10-16-pi-call.md`). The intake meeting on
  2026-10-10 left the definition open.
- **Decision:** The primary outcome is any sore throat at rest 30 minutes
  after PACU arrival, defined as `pacu30min_throatPain` > 0 on the 0-10
  scale.
- **Why:** It is the PI's primary question ("did it reduce sore throat
  afterwards?"). On the call the PI chose "any" (score > 0) with no
  higher threshold: "any is what patients notice".
- **Timing:** At planning, before any outcome was examined. The data file
  has not been opened.
- **Record updated:** 2026-10-16, after plan review, to cite the call note
  and correct the attribution; the decision itself is unchanged.
- **Alternatives:** A higher threshold on the 0-10 score (raised at intake;
  not chosen); the 0-10 score itself, analysed as ordinal (deferred; see
  the intake notes).

## D-002: "Does it last" is answered by an odds ratio at each time point

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst); the PI agreed to the
  population-averaged (population-level) odds ratio on a call on
  2026-10-16 (`notes/2026-10-16-pi-call.md`)
- **Decision:** Secondary outcomes are any sore throat at rest (score > 0)
  at PACU 90 min, 4 h after surgery and the first postoperative morning.
  "Does it last past the recovery room?" is answered by a separate
  treatment odds ratio at each of the four time points. One common odds
  ratio across the four time points is reported as a summary. The odds
  ratios are population-averaged (marginal). There is no formal test of a
  treatment-by-time interaction.
- **Why:** An odds ratio at each time point answers the client's question
  directly; a common odds ratio is a useful one-number summary.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** A formal treatment-by-time interaction test (not
  chosen); later time points only, without a summary.
- **Record updated:** 2026-10-16, after plan review, to cite the call
  note; the decision itself is unchanged. See D-013 and D-014 for how the
  per-time and common odds ratios are interpreted.

## D-003: No multiplicity adjustment

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** No adjustment for multiple comparisons.
- **Why:** There is one primary comparison; the secondary analyses are
  descriptive.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Holm or Bonferroni adjustment across the four time
  points.

## D-004: Cough is not analysed

- **Date:** 2026-10-16
- **Decided by:** PI, on a call on 2026-10-16
  (`notes/2026-10-16-pi-call.md`)
- **Decision:** Cough (at extubation and at each postoperative assessment)
  is not an outcome of this analysis.
- **Why:** The call note records "cough: not interested, drop it".
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Cough as a secondary outcome.
- **Record updated:** 2026-10-16, after plan review, to cite the call
  note; the decision itself is unchanged.

## D-005: Intention to treat, patient as unit, keep preoperative sore throat

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** The analysis population is all randomized patients,
  analysed in the group they were randomized to. The unit of analysis is
  the patient; the common odds ratio uses one row per patient per
  assessment, clustered on patient. Patients with a preoperative sore
  throat (`preOp_pain` = 1) are kept.
- **Why:** Intention to treat preserves randomization, and the file has no
  adherence or protocol-deviation variable for a per-protocol analysis.
  Excluding patients with a preoperative sore throat would change the
  population and could break randomization unless the protocol specified
  it. Whether the protocol excluded them is an open question.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Per-protocol analysis (not possible from this file);
  excluding patients with a preoperative sore throat.

## D-006: Report proportions and risk differences beside odds ratios

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** For the primary outcome and each assessment, report the
  proportion with any sore throat in each arm and the risk difference
  (licorice minus sugar water) with its 95% CI, beside the odds ratio.
- **Why:** When the outcome is common, the odds ratio overstates the
  relative risk; readers need the absolute difference.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Odds ratios only.

## D-007: Models for the primary, per-assessment and common odds ratios

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst). The PI agreed to unadjusted
  logistic regression at 30 minutes as the primary model on a call on
  2026-10-16 (`notes/2026-10-16-pi-call.md`); the remaining models are the
  analyst's call.
- **Decision:** The primary odds ratio and the odds ratio at each later
  assessment come from separate unadjusted logistic regressions of any sore
  throat on treatment, one per assessment. The common odds ratio comes from
  a GEE (logit link; treatment and assessment as a factor; exchangeable
  working correlation; robust standard errors; `geepack`). Wald 95% CIs
  throughout.
- **Why:** With treatment as the only term, the logistic odds ratio is the
  marginal odds ratio, so each separate fit estimates the agreed estimand
  (D-002) as a plain two-group comparison. Separate fits keep earlier
  assessments from informing later ones through the working correlation
  when data are missing. The GEE targets the marginal common odds ratio.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** One GEE with a treatment-by-assessment interaction for
  the per-assessment odds ratios; independence working correlation;
  profile-likelihood CIs.
- **Record updated:** 2026-10-16, after plan review, to cite the call note
  for the PI's agreement to the primary model; the decision itself is
  unchanged.

## D-008: Also fit a random-intercept mixed model, labeled conditional

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Fit a logistic mixed model with the same terms as the GEE
  and a random intercept for patient (`lme4`). Report its treatment odds
  ratio beside the GEE common odds ratio, clearly labeled as a
  patient-level (conditional) odds ratio. The GEE odds ratio remains the
  summary estimate.
- **Why:** Reviewers will ask for a mixed model. Showing both, labeled, is
  how we stop the larger conditional odds ratio being quoted as the effect.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Not fitting the mixed model (the earlier draft of the
  plan).

## D-009: Covariates for the adjusted sensitivity analysis

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** The adjusted sensitivity analysis adjusts for sex, age,
  BMI, ASA status, smoking and surgery size. Preoperative sore throat is
  included unless so few patients have it that its coefficient would be
  unstable; that is decided from the baseline count when the data arrive,
  without looking at outcomes, and logged. Mallampati class is not
  included. The adjusted odds ratio is reported as a conditional odds
  ratio, with an explanation of why it differs from the unadjusted one.
- **Why:** Covariates are chosen on prognostic grounds, before any data
  are seen. Mallampati predicts a difficult intubation rather than sore
  throat. The analysis is a sensitivity check, so the conditional odds
  ratio is reported as such rather than standardized.
- **Timing:** At planning, before any outcome was examined. The data file
  has not been opened.
- **Alternatives:** Standardization (g-computation) to a covariate-adjusted
  marginal odds ratio (not chosen); including Mallampati class.

## D-010: Missing outcomes: complete case, with bounds on the primary

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Every analysis uses the patients observed for the outcome
  at that assessment (complete case). For the primary outcome, also report
  best- and worst-case bounds. Any missing score is treated as missing;
  there is no variable for "not assessable".
- **Why:** At intake the client thought a couple of patients might have
  no postoperative data, though they were not sure. If missingness is that
  limited, complete case with bounds is enough; the bounds show the range
  the missing patients could move the primary result.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Multiple imputation; bounds for every assessment.

## D-011: Adjusted analysis: scope, covariate forms, preop sore throat rule

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Refines D-009. The adjusted sensitivity analysis is for the
  primary outcome only. Age and BMI enter as linear terms; ASA status,
  smoking and surgery size as factors. Preoperative sore throat is left
  out of the adjusted model if fewer than 10 patients have it, counted
  from baseline data only.
- **Why:** The cut-off fixes in advance the rule in D-009 (leave it out if
  so few patients have it that its coefficient would be unstable), so the
  choice does not depend on judgement after the data arrive. The covariate
  forms were proposed in drafting and confirmed by the analyst, so that
  they are fixed before any data are seen.
- **Timing:** At planning, before any outcome was examined. The data file
  has not been opened.
- **Alternatives:** Adjusted analyses at every assessment; splines for age
  and BMI; a judgement call on preoperative sore throat at data receipt.

## D-012: Report missingness by arm; revisit the approach if it is large

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Report the number of patients missing each outcome, by arm,
  in the data chapter. If missingness is more than the client expected,
  revisit the missing-data approach (D-010) before fitting any model, with
  a decision entry.
- **Why:** D-010 rests on the client's belief that only a couple of
  patients lack postoperative data; this checks that belief before any
  result is seen.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Proceed with complete case regardless of the amount
  missing.

## D-013: Durability is judged from per-time estimates, without testing

- **Date:** 2026-10-16
- **Decided by:** PI (per-time results descriptive); Matt Mulvahill
  (analyst; interpretation rule)
- **Decision:** No formal testing across time points; D-003 stands.
  Whether the effect lasts is judged from the per-time odds ratios, risk
  differences and their 95% CIs. A non-significant result at a later time
  point is not evidence that the effect wore off.
- **Why:** The PI wants the per-time results descriptive. The plan review
  pointed out that, without a stated interpretation, a null result on the
  first postoperative morning would be read as the effect wearing off,
  when it is only absence of evidence.
- **Timing:** At planning, after plan review, before any data were seen.
- **Alternatives:** Fixed-sequence testing (30 min, 90 min, 4 h, POD1,
  stopping at the first non-significant result), proposed in the plan
  review.

## D-014: The common odds ratio assumes one common effect

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Keep the exchangeable GEE common odds ratio (D-007) as a
  summary across all four time points, including 30 minutes. The plan
  states that it assumes one effect common to all time points and does not
  answer "does it last"; the per-time estimates do. The same applies to the
  mixed-model common odds ratio (D-008).
- **Why:** The plan review noted that if the effect changes over time the
  model is misspecified and the summary is a weighted average that leans
  toward the early, better-observed time points, so it could be quoted as
  a lasting effect.
- **Timing:** At planning, after plan review, before any data were seen.
- **Alternatives:** Drop the common odds ratio; an independence working
  correlation with stated weights; excluding 30 minutes from the summary.

## D-015: Missing data: MCAR assumption and a numeric revisit trigger

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Supersedes the trigger in D-012. The complete-case analyses
  assume outcomes are missing completely at random (MCAR). If more than 5%
  of patients are missing the outcome at any time point, the missing-data
  approach is revisited before any model is fitted, with a decision entry.
  Best- and worst-case bounds remain on the primary outcome only (D-010).
  Missingness by arm is still reported (D-012).
- **Why:** Complete case targets all randomized patients only under MCAR,
  so the assumption is stated. The review noted that "more than the
  client expected" left the trigger to be set after missingness was seen;
  a number fixes it in advance.
- **Timing:** At planning, after plan review, before any data were seen.
- **Alternatives:** A trigger on the between-arm difference in
  missingness; bounds at later time points too; naming a fallback such as
  multiple imputation now.

## D-016: Sparse covariate categories merged; Mallampati reason restated

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Adds to D-009 and D-011. In the adjusted model, any
  covariate category with fewer than 10 patients is merged into its
  neighbour, decided from baseline counts only. The adjusted odds ratio
  stays conditional. The reason for leaving out Mallampati class is
  restated: it acts through intubation difficulty, which is not measured,
  and leaving it out keeps the model small.
- **Why:** The review noted roughly 11 parameters with no rule for sparse
  categories, risking separation and unstable estimates. The original
  Mallampati reason ("predicts a difficult intubation rather than sore
  throat") was argued backwards, since difficult intubation plausibly
  causes sore throat.
- **Timing:** At planning, after plan review, before any data were seen.
- **Alternatives:** Standardization (g-computation) to a covariate-adjusted
  marginal odds ratio, proposed again in the review (not chosen); including
  Mallampati class.

## D-017: Verification additions

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** When data are simulated from a random-intercept model, the
  true marginal odds ratio for the recovery tests is computed by numerical
  integration over the random-intercept distribution. The Wald CI for the
  risk difference gets a known-answer test. Wald CIs for the risk
  difference are kept.
- **Why:** The marginal truth is not a model parameter, so the GEE recovery
  test needs it computed. Every calculation in the report needs a test.
- **Timing:** At planning, after plan review, before any data were seen.
- **Alternatives:** Newcombe intervals for the risk difference, suggested
  in the review for proportions near 0 or 1.

## D-018: Constant-effect simulation for the common OR; test the bounds

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** Adds to D-017. The recovery test for the common odds ratio
  (GEE and mixed model) simulates a treatment effect that is constant over
  time. The best- and worst-case bounds procedure gets a known-answer test.
- **Why:** The common odds ratio assumes one common effect (D-014); only
  with a constant simulated effect does it have a single true value to
  recover. The bounds are analysis logic and need a test like any other
  (CLAUDE.md rule 3). Both were raised in the plan review.
- **Timing:** After the plan was locked at `plan-v1`, before any data
  were seen. Not post hoc: no outcome or other data value had been
  examined. Changes verification only; no estimand, outcome or model
  changes.
- **Alternatives:** Simulating a time-varying effect and checking the
  weighted-average target; no dedicated test for the bounds.

## D-019: The delivered file is read-only and checksum-guarded

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst)
- **Decision:** `data/raw/licorice_gargle.csv`, the first delivery
  (received 2026-10-16 from the PI's fellow; the public `medicaldata`
  version), is the analysis's raw data, stored unchanged. Its MD5
  (`fe23d586f6bdc92a5db1342f8e41a283`) is recorded in
  `data/raw/README.md` and in `scripts/02_make_analysis_data.R`, which
  refuses to run if the file changes. Every cleaning step happens in code.
  A corrected or fuller file is saved as a new file with a new entry here.
- **Why:** Project rule (CLAUDE.md rule 2). Every result must trace back
  to bytes that can be shown to be the ones received. The file
  disagrees with the codebook's enrollment count (Chapter 1, open
  questions), so a second delivery is plausible and should not silently
  replace this one. The file is public and contains no identifiable data,
  so it is kept in `data/raw/` and committed. `data/phi/` is not used.
- **Timing:** At data receipt, after the plan was locked at `plan-v1`.
  Only the structure, the baseline codes, the validity of the outcome codes
  and the outcome missingness had been examined. No outcome distribution
  or comparison between arms had been seen. Not post hoc, and no change to
  the plan.
- **Alternatives:** Asking the client for a corrected file before
  starting; reading the data straight from the `medicaldata` package
  (rejected: the package version can change underneath the analysis).
