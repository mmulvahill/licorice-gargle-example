Every decision that could change a result is recorded here, with the
alternatives considered and who made it. Entries are never deleted; a
reversed decision gets a new entry that supersedes the old one. **Timing**
says whether any results had been seen when the decision was made: a change
made after seeing results is post hoc, and is marked as such here and in
the analysis plan. This file is a hand-written log, so its numbers are
typed; the report chapters compute theirs.

## D-001: Primary outcome is any sore throat at rest at PACU 30 min

- **Date:** 2026-10-16
- **Decided by:** PI (confirmed at the intake meeting; reported by Matt
  Mulvahill)
- **Decision:** The primary outcome is any sore throat at rest 30 minutes
  after PACU arrival, defined as `pacu30min_throatPain` > 0 on the 0-10
  scale.
- **Why:** It is the PI's primary question ("did it reduce sore throat
  afterwards?"), and the PI confirmed any sore throat as the primary
  outcome. "Any" means a score above 0.
- **Timing:** At planning, before any outcome was examined. The data file
  has not been opened.
- **Alternatives:** A higher threshold on the 0-10 score (raised at intake;
  not chosen); the 0-10 score itself, analysed as ordinal (deferred; see
  the intake notes).

## D-002: "Does it last" is answered by an odds ratio at each time point

- **Date:** 2026-10-16
- **Decided by:** Matt Mulvahill (analyst); the PI agreed to the
  population-averaged estimand on a call on 2026-10-16
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
- **Decided by:** PI
- **Decision:** Cough (at extubation and at each postoperative assessment)
  is not an outcome of this analysis.
- **Why:** The PI said cough is not of interest.
- **Timing:** At planning, before any outcome was examined.
- **Alternatives:** Cough as a secondary outcome.

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
- **Decided by:** Matt Mulvahill (analyst)
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
