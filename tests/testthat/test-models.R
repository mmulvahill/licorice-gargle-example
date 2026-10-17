test_that("odds_ratio matches the textbook 2x2 calculation for a glm", {
  # 2x2: A 30/50 with the outcome, B 15/50. OR = (15/35) / (30/20).
  d <- data.frame(
    arm = factor(rep(c("A", "B"), each = 50)),
    y = c(rep(1, 30), rep(0, 20), rep(1, 15), rep(0, 35))
  )
  fit <- stats::glm(y ~ arm, family = stats::binomial(), data = d)
  est <- odds_ratio(fit, "armB")
  expect_equal(est$or, (15 / 35) / (30 / 20), tolerance = 1e-6)
  expect_equal(est$n_obs, 100)
})

test_that("odds_ratio refuses a term that is not in the model", {
  d <- data.frame(arm = factor(c("A", "B", "A", "B")), y = c(1, 0, 0, 1))
  fit <- stats::glm(y ~ arm, family = stats::binomial(), data = d)
  expect_error(odds_ratio(fit, "age"), "not in model")
})
