# Every result the report uses, computed once.
#
# scripts/03_fit_models.R calls analysis_results() and saves the list to
# data/derived/results.rds. Chapters and index.qmd only read and format it,
# so a model is fitted once per change, not once per page, and the summary
# can never disagree with the chapter it summarises.

#' Fit every model and compute every estimate the report uses
#'
#' Wrap each fit in `fits$record("Label", ...)` so its warnings reach the
#' report (see `fit_warnings_note()`), and add each estimate to the list.
#'
#' @param clean The analysis data, from `scripts/02_make_analysis_data.R`.
#' @return A named list of estimates, plus `models` (the label of every fit)
#'   and `warnings` (one row per warning raised while fitting, by model).
analysis_results <- function(clean) {
  fits <- new_warning_log()

  list(
    models = fits$models(),
    warnings = fits$table()
  )
}

#' Collect warnings from model fits without hiding them
#'
#' `record(model, expr)` evaluates `expr`, notes any warning against `model`,
#' and lets the warning carry on so it still prints in the console. A warning
#' from a fit is a finding (CLAUDE.md), so it is kept for the report.
new_warning_log <- function() {
  models <- character()
  seen <- data.frame(model = character(), warning = character())
  list(
    record = function(model, expr) {
      models <<- c(models, model)
      withCallingHandlers(expr, warning = function(w) {
        seen[nrow(seen) + 1, ] <<- list(model, conditionMessage(w))
      })
    },
    models = function() models,
    table = function() seen
  )
}

#' Markdown note listing warnings from the named model fits
#'
#' For a chunk with `results: asis`, so each Results chapter says plainly
#' whether its models raised warnings.
fit_warnings_note <- function(results, models) {
  # A misspelt label would otherwise report "no warnings" for a model that
  # was never checked.
  unknown <- setdiff(models, results$models)
  if (length(unknown) > 0) {
    stop("Unknown model label(s): ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  w <- results$warnings[results$warnings$model %in% models, ]
  if (nrow(w) == 0) {
    return(cat("*No warnings from the model fits in this chapter.*\n"))
  }
  cat(
    "::: {.callout-important}\n## Model fit warnings\n",
    paste0("- **", w$model, ":** ", w$warning, "\n"),
    ":::\n",
    sep = ""
  )
}
