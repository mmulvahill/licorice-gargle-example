# Everything `make all` does, for machines without make (e.g. Windows).
# Run from the repo root: Rscript run_all.R

step <- function(label, expr) {
  message("\n== ", label)
  expr
}

step("Build analysis data", source("scripts/02_make_analysis_data.R"))
step("Fit models", source("scripts/03_fit_models.R"))
step("Tests", testthat::test_local(stop_on_failure = TRUE))

lint_status <- step("Lint", system2("Rscript", "scripts/lint.R"))
if (lint_status != 0) stop("Lint failed", call. = FALSE)

numbers_status <- step(
  "No typed numbers in prose",
  system2("Rscript", "scripts/check_inline_numbers.R")
)
if (numbers_status != 0) stop("Typed numbers found in prose", call. = FALSE)

render_status <- step("Render book", system2("quarto", "render"))
if (render_status != 0) stop("Render failed", call. = FALSE)
message("\nDone. Open _book/index.html")
