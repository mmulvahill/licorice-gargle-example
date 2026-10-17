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
# Stops, naming columns and rows, if the data disagree with the codebook
clean <- clean_raw(raw)
# Built here only to count its rows; analysis_results() rebuilds it from clean
long <- assessments_long(clean)

dir.create(here::here("data", "derived"), showWarnings = FALSE)
saveRDS(clean, here::here("data", "derived", "clean.rds"))

lineage <- data.frame(
  step = c("raw", "clean (one row per patient)", "long (one row per patient per assessment)"),
  rows = c(nrow(raw), nrow(clean), nrow(long)),
  file = c(
    file.path("data", "raw", basename(raw_path)), "data/derived/clean.rds",
    "assessments_long(clean)"
  )
)
saveRDS(lineage, here::here("data", "derived", "lineage.rds"))

message(sprintf(
  "raw %d rows -> clean %d rows -> long %d rows",
  nrow(raw), nrow(clean), nrow(long)
))
