# Simulation recovery for the mixed model: the slowest tests (adaptive
# quadrature, D-020). Each mixed-model check has its own file so they run in
# parallel with each other and with test-recovery.R. Shared set-up is in
# helper-recovery.R.

test_that("the mixed model recovers the conditional OR and the patient SD", {
  # Same seed as test-recovery.R, so these are the same simulated trials the
  # per-assessment fits use.
  set.seed(20261016)
  expect_glmm_recovers(simulate_constant_conditional(sd_patient), sd_patient)
})
