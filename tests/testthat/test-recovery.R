# Simulation recovery for the per-assessment fits, the GEE and the adjusted
# model. Shared set-up is in helper-recovery.R; the mixed model's tests are in
# test-recovery-glmm.R.

set.seed(20261016)
constant_conditional <- simulate_constant_conditional(sd_patient)

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

set.seed(20261017)
constant_marginal <- simulate_constant_marginal(sd_patient)

test_that("the exchangeable GEE recovers the common marginal OR", {
  expect_gee_recovers(constant_marginal)
})

test_that("the exchangeable GEE recovers the common marginal OR at the trial's patient SD", {
  set.seed(20261021)
  expect_gee_recovers(simulate_constant_marginal(sd_trial, n_sims_trial_sd))
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
