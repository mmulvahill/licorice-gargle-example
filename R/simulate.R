# Simulated trials with known answers, for the recovery tests in
# tests/testthat/test-models.R (CLAUDE.md rule 8). The structure copies the
# trial: patients randomized 1:1, four assessments of any sore throat, a
# random intercept per patient, and a couple of patients with no
# post-operative data at all.

#' Simulate the long data of a trial from a random-intercept logistic model
#'
#' The probability of sore throat for patient i at assessment t is
#' `plogis(eta[t] + b_i)`, with `b_i ~ N(0, sd_patient^2)` and `eta` taken from
#' `eta_sugar` or `eta_licorice` by arm.
#'
#' @param eta_sugar,eta_licorice Conditional log odds at each of the four
#'   assessments, by arm.
#' @param sd_patient Standard deviation of the patient random intercept.
#' @param n Number of patients.
#' @param n_no_postop Patients, chosen at random, with every outcome missing.
#' @return Data frame shaped like `assessments_long()`, without `throat_pain`.
simulate_trial <- function(eta_sugar, eta_licorice, sd_patient, n = 235, n_no_postop = 2) {
  labels <- unname(assessment_labels())
  arm <- sample(rep(c("Sugar water", "Licorice"), length.out = n))
  b <- stats::rnorm(n, 0, sd_patient)
  long <- data.frame(
    patient_id = rep(seq_len(n), each = length(labels)),
    treatment = factor(rep(arm, each = length(labels)), levels = c("Sugar water", "Licorice")),
    assessment = factor(rep(labels, times = n), levels = labels)
  )
  t <- as.integer(long$assessment)
  licorice <- long$treatment == "Licorice"
  eta <- ifelse(licorice, eta_licorice[t], eta_sugar[t]) + b[long$patient_id]
  long$sore_throat <- stats::rbinom(nrow(long), 1, stats::plogis(eta))
  long$sore_throat[long$patient_id %in% sample(n, n_no_postop)] <- NA
  long
}

#' Population-averaged risk under a random-intercept logistic model
#'
#' Integrates `plogis(eta + b)` over `b ~ N(0, sd^2)` numerically. This is the
#' marginal truth the plan asks for (D-017): it is not a model parameter.
marginal_risk <- function(eta, sd) {
  if (sd == 0) return(stats::plogis(eta))
  vapply(eta, function(e) {
    stats::integrate(
      function(b) stats::plogis(e + b) * stats::dnorm(b, 0, sd),
      -Inf, Inf, rel.tol = 1e-10
    )$value
  }, numeric(1))
}

#' Average within-patient correlation of the outcome across assessments
#'
#' The correlation between assessments s and t in one arm is
#' `(E[p_s p_t] - m_s m_t) / sqrt(m_s (1 - m_s) m_t (1 - m_t))`, with `p` the
#' patient's risk and `m` its mean over the random intercept. This averages it
#' over the pairs of assessments: what an exchangeable working correlation
#' estimates.
#'
#' @param eta Conditional log odds at each assessment, in one arm.
within_patient_correlation <- function(eta, sd) {
  m <- marginal_risk(eta, sd)
  pairs <- utils::combn(length(eta), 2)
  r <- apply(pairs, 2, function(st) {
    joint <- stats::integrate(
      function(b) {
        stats::plogis(eta[st[1]] + b) * stats::plogis(eta[st[2]] + b) * stats::dnorm(b, 0, sd)
      },
      -Inf, Inf, rel.tol = 1e-10
    )$value
    (joint - m[st[1]] * m[st[2]]) /
      sqrt(m[st[1]] * (1 - m[st[1]]) * m[st[2]] * (1 - m[st[2]]))
  })
  mean(r)
}

#' Marginal odds ratio, licorice against sugar water, at each assessment
marginal_or <- function(eta_sugar, eta_licorice, sd) {
  odds <- function(p) p / (1 - p)
  odds(marginal_risk(eta_licorice, sd)) / odds(marginal_risk(eta_sugar, sd))
}

#' Licorice log odds that give the same marginal odds ratio at every assessment
#'
#' With a constant conditional effect the marginal odds ratio drifts with the
#' baseline risk, so the common marginal odds ratio would have no single true
#' value (D-018). Solving for the licorice intercepts fixes it instead.
licorice_eta_for_marginal_or <- function(eta_sugar, or, sd) {
  p_sugar <- marginal_risk(eta_sugar, sd)
  target <- or * p_sugar / (1 - p_sugar)
  target <- target / (1 + target)
  vapply(target, function(p) {
    stats::uniroot(
      function(e) marginal_risk(e, sd) - p, c(-30, 30), tol = 1e-12
    )$root
  }, numeric(1))
}

#' Simulate one row per patient with baseline covariates and a primary outcome
#'
#' Covariate distributions roughly follow the trial's baseline data. The
#' outcome follows a logistic model, so its coefficients are the true
#' covariate-conditional log odds ratios.
#'
#' @param coef Named log odds: `intercept`, `licorice`, `female`, `age`
#'   (per year above 60), `bmi` (per unit above 26), `asa_ii`, `asa_iii`,
#'   `smoking_past`, `smoking_never`, `surgery_medium`, `surgery_large`,
#'   `preop_yes`.
#' @param p_preop Proportion with a preoperative sore throat.
#' @param n_missing Patients, chosen at random, missing the primary outcome.
#' @return Data frame shaped like `clean_raw()` for the columns the adjusted
#'   model uses; `throat_pain_pacu30` is 0 or 1.
simulate_baseline_trial <- function(coef, n = 235, p_preop = 0.1, n_missing = 2) {
  pick <- function(labels, prob) {
    factor(sample(labels, n, replace = TRUE, prob = prob), levels = labels)
  }
  d <- data.frame(
    patient_id = seq_len(n),
    treatment = factor(
      sample(rep(c("Sugar water", "Licorice"), length.out = n)),
      levels = c("Sugar water", "Licorice")
    ),
    sex = pick(c("Male", "Female"), c(0.6, 0.4)),
    age = round(pmin(pmax(stats::rnorm(n, 60, 14), 18), 90)),
    bmi = round(pmin(pmax(stats::rnorm(n, 26, 4), 15), 40), 1),
    asa = pick(c("I", "II", "III"), c(0.17, 0.57, 0.26)),
    smoking = pick(c("Current", "Past", "Never"), c(0.38, 0.31, 0.31)),
    surgery_size = pick(c("Small", "Medium", "Large"), c(0.24, 0.67, 0.09)),
    preop_sore_throat = pick(c("No", "Yes"), c(1 - p_preop, p_preop))
  )
  eta <- coef[["intercept"]] +
    coef[["licorice"]] * (d$treatment == "Licorice") +
    coef[["female"]] * (d$sex == "Female") +
    coef[["age"]] * (d$age - 60) +
    coef[["bmi"]] * (d$bmi - 26) +
    coef[["asa_ii"]] * (d$asa == "II") + coef[["asa_iii"]] * (d$asa == "III") +
    coef[["smoking_past"]] * (d$smoking == "Past") +
    coef[["smoking_never"]] * (d$smoking == "Never") +
    coef[["surgery_medium"]] * (d$surgery_size == "Medium") +
    coef[["surgery_large"]] * (d$surgery_size == "Large") +
    coef[["preop_yes"]] * (d$preop_sore_throat == "Yes")
  d$throat_pain_pacu30 <- stats::rbinom(n, 1, stats::plogis(eta))
  d$throat_pain_pacu30[sample(n, n_missing)] <- NA
  d
}
