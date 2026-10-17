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
  long <- assessments_long(clean)

  per_assessment <- do.call(rbind, lapply(levels(long$assessment), function(a) {
    fits$record(paste("Logistic regression,", a), fit_assessment(long, a))
  }))

  # list() evaluates in order, so models and warnings come after every fit
  list(
    n_patients = nrow(clean),
    n_by_arm = c(table(clean$treatment)),
    baseline = table_one(clean, "treatment", baseline_vars()),
    preop_sore_throat_n = sum(clean$preop_sore_throat == "Yes"),
    missing = missing_by_arm(long),
    no_postop_n = sum(tapply(is.na(long$sore_throat), long$patient_id, all)),
    per_assessment = per_assessment,
    primary = per_assessment[1, ],
    gee = fits$record("GEE, common marginal OR", fit_gee_common(long)),
    glmm = fits$record("Mixed model, common conditional OR", fit_glmm_common(long)),
    adjusted = fits$record("Adjusted logistic regression", fit_adjusted(clean)),
    bounds = fits$record(
      "Best- and worst-case bounds",
      missing_bounds(any_sore_throat(clean$throat_pain_pacu30), clean$treatment)
    ),
    models = fits$models(),
    warnings = fits$table()
  )
}

#' The baseline variables in Table 1, in display order
baseline_vars <- function() {
  c("age", "sex", "bmi", "asa", "mallampati", "smoking", "preop_sore_throat", "surgery_size")
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
