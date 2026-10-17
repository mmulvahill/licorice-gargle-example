# Raw -> clean. Every recode lives here, never in a chapter.
# Add the project's cleaning function (raw data frame -> one row per unit)
# and its validation here, with known-answer tests in tests/testthat/.

#' Recode a numeric column to a factor, refusing codes the codebook lacks
#'
#' `factor()` silently turns an unexpected code into NA. That is how a
#' miscoded value disappears from an analysis, so this errors instead.
recode_factor <- function(x, levels, labels = levels, name = "x") {
  unexpected <- setdiff(unique(x[!is.na(x)]), levels)
  if (length(unexpected) > 0) {
    stop(
      sprintf(
        "Column '%s' has codes not in the codebook: %s",
        name, paste(sort(unexpected), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  factor(x, levels = levels, labels = labels)
}
