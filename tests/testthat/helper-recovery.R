# Shared set-up for the simulation-recovery tests (CLAUDE.md rule 8), split
# across the test-recovery*.R files so the slow mixed-model fits run in
# parallel. Each model is fitted to many simulated trials
# of the real trial's size and structure (R/simulate.R) and must recover its
# own estimand: mean estimate near the truth, Wald 95% CIs that cover it about
# 95% of the time, and standard errors that match the spread of the
# estimates. The marginal truth comes from numerical integration over the
# random intercept (D-017). Seeds are fixed, so these tests give the same
# answer every run.

n_sims <- 200
# The trial-strength clustering checks (SD 2.75) are a robustness check on
# top of the main recovery tests, so they use fewer simulated trials.
n_sims_trial_sd <- 100

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
# simulated trials (same seed in both files) and must each recover their own,
# different, estimand.
conditional_log_or <- log(0.4)
simulate_constant_conditional <- function(sd, n = n_sims) {
  lapply(seq_len(n), function(i) {
    simulate_trial(eta_sugar, eta_sugar + conditional_log_or, sd)
  })
}

expect_glmm_recovers <- function(sims, sd) {
  fits <- with_warnings(lapply(sims, fit_glmm_common))
  est <- do.call(rbind, fits$value)
  expect_recovers(est, conditional_log_or, max_bias = 0.08, label = "Mixed model OR")
  expect_lt(abs(mean(est$sd_patient) - sd), 0.1)
  # Warnings are findings: the fitting method must not make them routine
  expect_lte(length(fits$warnings), 0.05 * length(sims))
  expect_true(all(est$n_patients == 233))
}

# Scenario 2: one marginal odds ratio at every assessment, so the GEE's common
# odds ratio has a single true value (D-018). The conditional effect then has
# to change over time; licorice_eta_for_marginal_or() solves for it.
marginal_log_or <- log(0.5)
simulate_constant_marginal <- function(sd, n = n_sims) {
  eta_licorice <- licorice_eta_for_marginal_or(eta_sugar, exp(marginal_log_or), sd)
  list(
    sd = sd, eta_licorice = eta_licorice,
    sims = lapply(seq_len(n), function(i) simulate_trial(eta_sugar, eta_licorice, sd))
  )
}

expect_gee_recovers <- function(scenario) {
  fits <- with_warnings(lapply(scenario$sims, fit_gee_common))
  expect_length(fits$warnings, 0)
  est <- do.call(rbind, fits$value)
  expect_recovers(est, marginal_log_or, max_bias = 0.06, label = "GEE OR")
  expect_true(all(est$n_patients == 233))
  # An independence GEE gives the same OR and valid sandwich CIs, so only the
  # working correlation shows the plan's exchangeable structure is in use.
  # Its truth, like the marginal OR's, comes from integration.
  truth <- mean(c(
    within_patient_correlation(eta_sugar, scenario$sd),
    within_patient_correlation(scenario$eta_licorice, scenario$sd)
  ))
  expect_false(anyNA(est$working_correlation))
  expect_lt(abs(mean(est$working_correlation) - truth), 0.02)
}

# Scenario 4: the trial's own clustering. On the trial data the mixed model
# estimated a patient SD of about 2.76, far above the 1.5 above, so the two
# models that depend on the clustering are checked again at that strength.
sd_trial <- 2.75
