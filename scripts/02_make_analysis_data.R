# Raw -> analysis data. Run with `make data` (or Rscript from the repo root).
#
# data/raw is read-only: this script refuses to run if the raw file's bytes
# differ from the checksum recorded when it was received.
#
# When data arrives: set raw_path (and RAW_DATA in the Makefile), record the
# MD5 below and in data/raw/README.md, and write the cleaning function in R/.

pkgload::load_all(here::here(), quiet = TRUE)

raw_path <- here::here("data", "raw", "licorice_gargle.csv")
expected_md5 <- "fe23d586f6bdc92a5db1342f8e41a283"

if (!file.exists(raw_path)) {
  stop("No raw data yet: ", raw_path, " does not exist.", call. = FALSE)
}
actual_md5 <- unname(tools::md5sum(raw_path))
if (!identical(actual_md5, expected_md5)) {
  stop(
    basename(raw_path), " has changed (md5 ", actual_md5,
    ", expected ", expected_md5, "). Raw data is read-only: if a new ",
    "delivery arrived, save it as a new file and log it in DECISIONS.md.",
    call. = FALSE
  )
}

raw <- utils::read.csv(raw_path)
clean <- raw # Replace with the project's cleaning function from R/clean.R.

dir.create(here::here("data", "derived"), showWarnings = FALSE)
saveRDS(clean, here::here("data", "derived", "clean.rds"))

lineage <- data.frame(
  step = c("raw", "clean"),
  rows = c(nrow(raw), nrow(clean)),
  file = c(file.path("data", "raw", basename(raw_path)), "data/derived/clean.rds")
)
saveRDS(lineage, here::here("data", "derived", "lineage.rds"))

message(sprintf("raw %d rows -> clean %d rows", nrow(raw), nrow(clean)))
