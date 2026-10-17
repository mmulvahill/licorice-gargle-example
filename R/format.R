# Formatting helpers for inline numbers in the Quarto book.
# Prose never contains typed numbers; it calls these (see CLAUDE.md).

fmt_num <- function(x, digits = 1) formatC(x, format = "f", digits = digits)

fmt_pct <- function(x, digits = 0) paste0(fmt_num(100 * x, digits), "%")

fmt_p <- function(p) {
  ifelse(p < 0.001, "p < 0.001", paste0("p = ", fmt_num(p, 3)))
}

#' "OR 0.42, 95% CI 0.24 to 0.74" from a row of `odds_ratio()`
fmt_or <- function(or_row, digits = 2) {
  sprintf(
    "OR %s, 95%% CI %s to %s",
    fmt_num(or_row$or, digits),
    fmt_num(or_row$lower, digits),
    fmt_num(or_row$upper, digits)
  )
}

#' "0.41 (0.22 to 0.74)" for table cells, vectorised over rows
fmt_or_cell <- function(or, lower, upper, digits = 2) {
  sprintf("%s (%s to %s)", fmt_num(or, digits), fmt_num(lower, digits), fmt_num(upper, digits))
}
