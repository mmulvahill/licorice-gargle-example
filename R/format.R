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

#' "42 of 116 (36%)" from a proportion and its denominator, vectorised
fmt_prop <- function(p, n, digits = 0) {
  sprintf("%d of %d (%s)", as.integer(round(p * n)), as.integer(n), fmt_pct(p, digits))
}

#' "-17.4 percentage points (95% CI -28.7 to -6.2)" from `risk_difference()`
fmt_rd <- function(rd_row, digits = 1) {
  sprintf(
    "%s percentage points (95%% CI %s to %s)",
    fmt_num(100 * rd_row$rd, digits),
    fmt_num(100 * rd_row$rd_lower, digits),
    fmt_num(100 * rd_row$rd_upper, digits)
  )
}

#' "-17.4 (-28.7 to -6.2)" in percentage points, for table cells
fmt_rd_cell <- function(rd, lower, upper, digits = 1) {
  fmt_or_cell(100 * rd, 100 * lower, 100 * upper, digits)
}

#' "0.41 (0.22 to 0.74)" for table cells, vectorised over rows
fmt_or_cell <- function(or, lower, upper, digits = 2) {
  sprintf("%s (%s to %s)", fmt_num(or, digits), fmt_num(lower, digits), fmt_num(upper, digits))
}
