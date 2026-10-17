# Descriptive summaries. Tested against hand-computed answers.

#' A simple Table 1: mean (SD) for numeric, n (%) for factor variables
#'
#' @param data Data frame.
#' @param by Name of the grouping column (e.g. "treatment").
#' @param vars Character vector of columns to summarise.
#' @param digits Decimal places for means, SDs and percentages.
#' @return Data frame with a `variable` column, a `level` column and one
#'   column per group, as character.
table_one <- function(data, by, vars, digits = 1) {
  groups <- levels(factor(data[[by]]))
  fmt <- function(x) formatC(x, format = "f", digits = digits)

  rows <- lapply(vars, function(v) {
    x <- data[[v]]
    if (is.numeric(x)) {
      cells <- vapply(groups, function(g) {
        xi <- x[data[[by]] == g]
        sprintf("%s (%s)", fmt(mean(xi, na.rm = TRUE)), fmt(stats::sd(xi, na.rm = TRUE)))
      }, character(1))
      data.frame(variable = v, level = "mean (SD)", t(cells), check.names = FALSE)
    } else {
      x <- factor(x)
      do.call(rbind, lapply(levels(x), function(lev) {
        cells <- vapply(groups, function(g) {
          in_group <- data[[by]] == g & !is.na(x)
          n <- sum(x[in_group] == lev)
          sprintf("%d (%s%%)", n, fmt(100 * n / sum(in_group)))
        }, character(1))
        data.frame(variable = v, level = lev, t(cells), check.names = FALSE)
      }))
    }
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

#' Missing outcomes at each assessment, by arm and overall (D-012)
#'
#' @param long Output of `assessments_long()`.
#' @return One row per assessment: patients and missing outcomes in each arm,
#'   and the proportion missing overall (the D-015 trigger is above 0.05).
missing_by_arm <- function(long) {
  out <- do.call(rbind, lapply(levels(long$assessment), function(a) {
    d <- long[long$assessment == a, ]
    sugar <- d$treatment == "Sugar water"
    miss <- is.na(d$sore_throat)
    data.frame(
      assessment = a,
      n_sugar = sum(sugar), missing_sugar = sum(miss & sugar),
      n_licorice = sum(!sugar), missing_licorice = sum(miss & !sugar),
      prop_missing = mean(miss)
    )
  }))
  rownames(out) <- NULL
  out
}
