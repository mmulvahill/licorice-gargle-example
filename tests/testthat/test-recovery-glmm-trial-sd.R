# Simulation recovery for the mixed model at the trial's own clustering (SD
# 2.75). Separate from test-recovery-glmm.R so the two slow files run in
# parallel. Shared set-up is in helper-recovery.R.

test_that("the mixed model recovers the conditional OR at the trial's patient SD", {
  set.seed(20261020)
  expect_glmm_recovers(simulate_constant_conditional(sd_trial, n_sims_trial_sd), sd_trial)
})
