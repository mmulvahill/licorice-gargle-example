# Simulation recovery (CLAUDE.md rule 8). Each model is fitted to many
# simulated trials of the real trial's size and structure (R/simulate.R) and
# must recover its own estimand: mean estimate near the truth, Wald 95% CIs
# that cover it about 95% of the time, and standard errors that match the
# spread of the estimates. The marginal truth comes from numerical
# integration over the random intercept (D-017). Seeds are fixed, so these
# tests give the same answer every run.

n_sims <- 200

# Conditional log odds at the four assessments in the sugar-water arm, with
# sore throat becoming less common over time, and a patient random intercept
# strong enough that ignoring it matters.
eta_sugar <- c(0.8, 0.3, -0.2, -1)
sd_patient <- 1.5

# Evaluate expr, keeping its warnings to check rather than letting them print
with_warnings <- function(expr) {
  seen <- character()
  value <- withCallingHandlers(expr, warning = function(w) {
    seen <<- c(seen, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  list(value = value, warnings = seen)
}

# Summarise estimates (rows from odds_ratio()) against a true log odds ratio
recovery <- function(est, truth) {
  list(
    bias = mean(est$log_or) - truth,
    coverage = mean(est$lower < exp(truth) & exp(truth) < est$upper),
    se_ratio = mean(est$se) / stats::sd(est$log_or)
  )
}

expect_recovers <- function(est, truth, max_bias, label) {
  r <- recovery(est, truth)
  expect_lt(abs(r$bias), max_bias, label = paste(label, "bias"))
  expect_gte(r$coverage, 0.91, label = paste(label, "CI coverage"))
  expect_lte(r$coverage, 0.985, label = paste(label, "CI coverage"))
  expect_gt(r$se_ratio, 0.85, label = paste(label, "SE / SD of estimates"))
  expect_lt(r$se_ratio, 1.2, label = paste(label, "SE / SD of estimates"))
}

# Scenario 1: one conditional (patient-level) odds ratio at every assessment.
# The per-assessment logistic fits and the mixed model are fitted to the same
# simulated trials and must each recover their own, different, estimand.
conditional_log_or <- log(0.4)
set.seed(20261016)
constant_conditional <- lapply(seq_len(n_sims), function(i) {
  simulate_trial(eta_sugar, eta_sugar + conditional_log_or, sd_patient)
})

test_that("the marginal and conditional truths differ in scenario 1", {
  marginal <- log(marginal_or(eta_sugar, eta_sugar + conditional_log_or, sd_patient))
  # About 0.25 on the log scale: far more than the bias the tests allow
  expect_true(all(marginal - conditional_log_or > 0.2))
})

test_that("per-assessment logistic fits recover the marginal OR and risk difference", {
  fits <- with_warnings(lapply(constant_conditional, function(long) {
    do.call(rbind, lapply(levels(long$assessment), function(a) fit_assessment(long, a)))
  }))
  expect_length(fits$warnings, 0)
  est <- do.call(rbind, fits$value)
  truth_or <- log(marginal_or(eta_sugar, eta_sugar + conditional_log_or, sd_patient))
  truth_rd <- marginal_risk(eta_sugar + conditional_log_or, sd_patient) -
    marginal_risk(eta_sugar, sd_patient)
  for (t in seq_along(truth_or)) {
    at <- est[est$assessment == levels(constant_conditional[[1]]$assessment)[t], ]
    expect_recovers(at, truth_or[t], max_bias = 0.08, label = paste("Assessment", t, "OR"))
    expect_lt(abs(mean(at$rd) - truth_rd[t]), 0.015, label = paste("Assessment", t, "RD bias"))
    covered <- mean(at$rd_lower < truth_rd[t] & truth_rd[t] < at$rd_upper)
    expect_gte(covered, 0.91, label = paste("Assessment", t, "RD CI coverage"))
    expect_lte(covered, 0.985, label = paste("Assessment", t, "RD CI coverage"))
    # Every simulated trial has two patients with no post-operative data
    expect_true(all(at$n_sugar + at$n_licorice == 233))
  }
})

test_that("the mixed model recovers the conditional OR and the patient SD", {
  fits <- with_warnings(lapply(constant_conditional, fit_glmm_common))
  est <- do.call(rbind, fits$value)
  expect_recovers(est, conditional_log_or, max_bias = 0.08, label = "Mixed model OR")
  expect_lt(abs(mean(est$sd_patient) - sd_patient), 0.1)
  # Warnings are findings: the fitting method must not make them routine
  expect_lte(length(fits$warnings), 0.05 * n_sims)
  expect_true(all(est$n_patients == 233))
})

# Scenario 2: one marginal odds ratio at every assessment, so the GEE's common
# odds ratio has a single true value (D-018). The conditional effect then has
# to change over time; licorice_eta_for_marginal_or() solves for it.
marginal_log_or <- log(0.5)
eta_licorice_marginal <- licorice_eta_for_marginal_or(
  eta_sugar, exp(marginal_log_or), sd_patient
)
set.seed(20261017)
constant_marginal <- lapply(seq_len(n_sims), function(i) {
  simulate_trial(eta_sugar, eta_licorice_marginal, sd_patient)
})

test_that("the exchangeable GEE recovers the common marginal OR", {
  fits <- with_warnings(lapply(constant_marginal, fit_gee_common))
  expect_length(fits$warnings, 0)
  est <- do.call(rbind, fits$value)
  expect_recovers(est, marginal_log_or, max_bias = 0.06, label = "GEE OR")
  expect_true(all(est$n_patients == 233))
  # An independence GEE gives the same OR and valid sandwich CIs, so only the
  # working correlation shows the plan's exchangeable structure is in use.
  # Its truth, like the marginal OR's, comes from integration.
  truth <- mean(c(
    within_patient_correlation(eta_sugar, sd_patient),
    within_patient_correlation(eta_licorice_marginal, sd_patient)
  ))
  expect_false(anyNA(est$working_correlation))
  expect_lt(abs(mean(est$working_correlation) - truth), 0.02)
})

# Scenario 3: one row per patient, with covariates that predict sore throat
# strongly, so leaving them out changes the conditional odds ratio.
adjusted_coef <- c(
  intercept = 0.2, licorice = log(0.4), female = 0.8, age = 0.04, bmi = 0.05,
  asa_ii = 0.3, asa_iii = 1.0, smoking_past = -0.3, smoking_never = -0.6,
  surgery_medium = 0.5, surgery_large = 1.0, preop_yes = 1.5
)

test_that("the adjusted model recovers the covariate-conditional OR", {
  set.seed(20261018)
  fits <- with_warnings(lapply(seq_len(n_sims), function(i) {
    fit_adjusted(simulate_baseline_trial(adjusted_coef))
  }))
  est <- do.call(rbind, fits$value)
  expect_recovers(est, adjusted_coef[["licorice"]], max_bias = 0.1, label = "Adjusted OR")
  expect_lte(length(fits$warnings), 0.05 * n_sims)
  # A small-sample average cannot separate a mild omission from small-sample
  # bias, so one large trial checks the point estimate tightly.
  set.seed(20261019)
  big <- fit_adjusted(simulate_baseline_trial(adjusted_coef, n = 50000))
  expect_lt(abs(big$log_or - adjusted_coef[["licorice"]]), 0.06)
  expect_equal(
    big$covariates,
    "age, bmi, sex, asa, smoking, surgery_size, preop_sore_throat"
  )
})
