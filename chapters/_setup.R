# Sourced at the top of every chapter. Loads project functions, the derived
# data written by `make data`, and the results written by `make results`.
# Chapters never read data/raw and never fit models.
# Before data arrives, `has_data` is FALSE and chapters skip data chunks.

pkgload::load_all(here::here(), quiet = TRUE)

derived <- here::here("data", "derived")
needed <- file.path(derived, c("clean.rds", "lineage.rds", "results.rds"))
has_data <- file.exists(file.path(derived, "clean.rds"))
if (has_data && !all(file.exists(needed))) {
  stop("Derived data or results not found. Run `make results` first.", call. = FALSE)
}

if (has_data) {
  # Rendering outside make (e.g. the RStudio Render button) skips the refit,
  # so refuse results older than the data or code that produced them rather
  # than show stale numbers.
  inputs <- c(
    file.path(derived, "clean.rds"),
    here::here("scripts", "03_fit_models.R"),
    list.files(here::here("R"), pattern = "\\.R$", full.names = TRUE)
  )
  if (any(file.mtime(inputs) > file.mtime(file.path(derived, "results.rds")))) {
    stop("Results are older than the data or code. Run `make results`.", call. = FALSE)
  }

  clean <- readRDS(file.path(derived, "clean.rds"))
  lineage <- readRDS(file.path(derived, "lineage.rds"))
  results <- readRDS(file.path(derived, "results.rds"))
}
