# The report reads one results list. These tests check its shape and that
# warnings from model fits are kept.

test_that("analysis_results returns the model labels and warning table", {
  set.seed(5)
  results <- analysis_results(simulate_clean())
  expect_true(all(c("models", "warnings") %in% names(results)))
  expect_named(results$warnings, c("model", "warning"))
})

test_that("analysis_results records every fit and every estimate the chapters use", {
  set.seed(6)
  results <- analysis_results(simulate_clean())
  expect_equal(results$models, c(
    paste("Logistic regression,", assessment_labels()),
    "GEE, common marginal OR", "Mixed model, common conditional OR",
    "Adjusted logistic regression", "Best- and worst-case bounds",
    "Worst-case bound with absent patients (post hoc)"
  ))
  expect_equal(results$n_patients, 235)
  expect_equal(results$n_enrolled, 236)
  expect_equal(results$absent_bound$n_absent, 1)
  expect_equal(results$absent_bound$n_obs, 236)
  expect_equal(results$baseline_missing_n, 0)
  expect_type(results$adjusted_merged, "character")
  expect_equal(sum(results$n_by_arm), 235)
  expect_equal(nrow(results$per_assessment), 4)
  expect_equal(results$primary$assessment, "PACU 30 min")
  expect_equal(results$primary, results$per_assessment[1, ])
  expect_equal(results$no_postop_n, 2)
  expect_equal(results$bounds$n_filled, c(2, 2))
  expect_equal(results$missing$missing_sugar + results$missing$missing_licorice, rep(2, 4))
  expect_true(all(c("gee", "glmm", "adjusted", "baseline") %in% names(results)))
})

test_that("the warning log keeps a warning and still lets it through", {
  fits <- new_warning_log()
  expect_warning(
    value <- fits$record("Toy model", {
      warning("fitted probabilities numerically 0 or 1 occurred")
      42
    }),
    "numerically 0 or 1"
  )
  expect_equal(value, 42)
  fits$record("Quiet model", 1)
  expect_equal(fits$models(), c("Toy model", "Quiet model"))
  expect_equal(fits$table()$model, "Toy model")
  expect_match(fits$table()$warning, "numerically 0 or 1")
})

test_that("a separated logistic fit's warning reaches the results", {
  # Age perfectly separates the outcome, so glm warns. That warning must end
  # up in the report, not vanish in a hidden chunk. (A binary predictor that
  # separates the outcome gives no warning at all, only an absurd odds
  # ratio: another reason to read the estimates.)
  d <- data.frame(age = 1:40, y = rep(c(0, 1), each = 20))
  fits <- new_warning_log()
  suppressWarnings(fits$record(
    "Separated",
    stats::glm(y ~ age, family = stats::binomial(), data = d)
  ))
  expect_match(fits$table()$warning, "numerically 0 or 1", all = FALSE)
  expect_true(all(fits$table()$model == "Separated"))
})

test_that("fit_warnings_note reports warnings, or says there were none", {
  results <- list(
    models = c("A", "B"),
    warnings = data.frame(model = "B", warning = "did not converge")
  )
  expect_output(fit_warnings_note(results, "A"), "No warnings")
  expect_output(fit_warnings_note(results, c("A", "B")), "B:\\*\\* did not converge")
})

test_that("fit_warnings_note refuses a model label it does not know", {
  results <- list(models = "Mixed model", warnings = data.frame(model = character(),
                                                                warning = character()))
  expect_error(fit_warnings_note(results, "Mixed modle"), "Unknown model label")
})
