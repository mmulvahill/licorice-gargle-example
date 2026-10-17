# The report reads one results list. These tests check its shape and that
# warnings from model fits are kept.

test_that("analysis_results returns the model labels and warning table", {
  results <- analysis_results(data.frame(x = 1:3))
  expect_true(all(c("models", "warnings") %in% names(results)))
  expect_named(results$warnings, c("model", "warning"))
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
