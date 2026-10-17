# Analysis data -> results. Run with `make results` (or Rscript from the repo
# root).
#
# Fits every model once and saves the estimates the report uses. Chapters
# read data/derived/results.rds; they never fit models themselves. If a model
# becomes slow, give it its own script and Makefile rule so editing other
# code does not refit it.

pkgload::load_all(here::here(), quiet = TRUE)

derived <- here::here("data", "derived")
clean <- readRDS(file.path(derived, "clean.rds"))

results <- analysis_results(clean)
saveRDS(results, file.path(derived, "results.rds"))

message(sprintf(
  "%d models fitted; results saved to data/derived/results.rds; %d warning(s)",
  length(results$models), nrow(results$warnings)
))
