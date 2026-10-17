# Raw -> clean. Every recode lives here, never in a chapter.
#
# The codebook is notes/2026-10-16-codebook.md. raw_codebook() is its copy in
# code, and every check below is against it, so a delivery that disagrees
# with the codebook stops the pipeline instead of flowing into a model.

#' The codebook: raw column, clean name, and allowed values
#'
#' Coded columns become factors with these labels, the first level being the
#' reference. Scores must be whole numbers in range. The codebook gives no
#' range for age or BMI, so their bounds only catch impossible values.
raw_codebook <- function() {
  factors <- list(
    preOp_gender = list(name = "sex", codes = 0:1, labels = c("Male", "Female")),
    preOp_asa = list(name = "asa", codes = 1:3, labels = c("I", "II", "III")),
    preOp_mallampati = list(
      name = "mallampati", codes = 1:4, labels = c("I", "II", "III", "IV")
    ),
    preOp_smoking = list(
      name = "smoking", codes = 1:3, labels = c("Current", "Past", "Never")
    ),
    preOp_pain = list(name = "preop_sore_throat", codes = 0:1, labels = c("No", "Yes")),
    # Sugar water first: every odds ratio is licorice against sugar water
    treat = list(name = "treatment", codes = 0:1, labels = c("Sugar water", "Licorice")),
    intraOp_surgerySize = list(
      name = "surgery_size", codes = 1:3, labels = c("Small", "Medium", "Large")
    )
  )
  numbers <- data.frame(
    raw = c(
      "preOp_calcBMI", "preOp_age", "extubation_cough", "pacu30min_cough",
      "pacu30min_throatPain", "pacu30min_swallowPain", "pacu90min_cough",
      "pacu90min_throatPain", "postOp4hour_cough", "postOp4hour_throatPain",
      "pod1am_cough", "pod1am_throatPain"
    ),
    name = c(
      "bmi", "age", "cough_extubation", "cough_pacu30",
      "throat_pain_pacu30", "swallow_pain_pacu30", "cough_pacu90",
      "throat_pain_pacu90", "cough_4h", "throat_pain_4h",
      "cough_pod1", "throat_pain_pod1"
    ),
    min = c(10, 0, rep(0, 10)),
    max = c(80, 120, 3, 3, 10, 10, 3, 10, 3, 10, 3, 10),
    whole = c(FALSE, FALSE, rep(TRUE, 10))
  )
  list(factors = factors, numbers = numbers, required = "treat")
}

#' Raw delivery -> one row per patient, validated and labeled
#'
#' The file has no patient identifier, so `patient_id` is the row number in
#' the raw file; it is stable only while the raw file is unchanged, which
#' the checksum guarantees.
#'
#' @param raw Data frame read from the raw CSV.
#' @return Data frame with `patient_id`, labeled factors and numeric scores.
clean_raw <- function(raw) {
  problems <- validate_raw(raw)
  if (length(problems) > 0) {
    stop(
      "The raw data disagree with the codebook:\n",
      paste0("- ", problems, collapse = "\n"),
      call. = FALSE
    )
  }
  book <- raw_codebook()
  clean <- data.frame(patient_id = seq_len(nrow(raw)))
  for (col in names(book$factors)) {
    spec <- book$factors[[col]]
    clean[[spec$name]] <- recode_factor(raw[[col]], spec$codes, spec$labels, col)
  }
  for (i in seq_len(nrow(book$numbers))) {
    clean[[book$numbers$name[i]]] <- as.numeric(raw[[book$numbers$raw[i]]])
  }
  clean
}

#' Every way the raw data disagree with the codebook, one message each
#'
#' @return Character vector; empty when the data agree.
validate_raw <- function(raw) {
  book <- raw_codebook()
  expected <- c(names(book$factors), book$numbers$raw)
  absent <- setdiff(expected, names(raw))
  extra <- setdiff(names(raw), expected)
  problems <- character()
  if (length(absent) > 0) {
    problems <- c(problems, paste("Columns missing:", paste(absent, collapse = ", ")))
  }
  if (length(extra) > 0) {
    problems <- c(problems, paste("Columns not in the codebook:", paste(extra, collapse = ", ")))
  }

  for (col in intersect(book$required, names(raw))) {
    missing_rows <- which(is.na(raw[[col]]))
    if (length(missing_rows) > 0) {
      problems <- c(problems, sprintf(
        "Column '%s' is missing in %s", col, fmt_rows(missing_rows)
      ))
    }
  }

  for (col in intersect(names(book$factors), names(raw))) {
    x <- raw[[col]]
    bad <- which(!is.na(x) & !x %in% book$factors[[col]]$codes)
    if (length(bad) > 0) {
      problems <- c(problems, sprintf(
        "Column '%s' has codes not in the codebook: %s (%s)",
        col, paste(sort(unique(x[bad])), collapse = ", "), fmt_rows(bad)
      ))
    }
  }

  for (i in which(book$numbers$raw %in% names(raw))) {
    spec <- book$numbers[i, ]
    x <- raw[[spec$raw]]
    if (!is.numeric(x)) {
      # Without this, as.numeric() would turn "n/a" into a silent NA
      text <- which(!is.na(x) & is.na(suppressWarnings(as.numeric(x))))
      problems <- c(problems, sprintf(
        "Column '%s' has values that are not a number in %s", spec$raw, fmt_rows(text)
      ))
      next
    }
    bad <- which(!is.na(x) & (x < spec$min | x > spec$max | (spec$whole & x != round(x))))
    if (length(bad) > 0) {
      problems <- c(problems, sprintf(
        "Column '%s' must be %s%s to %s; not so in %s",
        spec$raw, if (spec$whole) "whole numbers from " else "",
        spec$min, spec$max, fmt_rows(bad)
      ))
    }
  }
  problems
}

#' "row 3" or "rows 2, 4, ..." naming data rows in the raw file
#'
#' Rows count data lines, so row 1 is the line after the header.
fmt_rows <- function(rows, max_shown = 10) {
  shown <- paste(utils::head(rows, max_shown), collapse = ", ")
  more <- if (length(rows) > max_shown) sprintf(" and %d more", length(rows) - max_shown)
  paste0(if (length(rows) == 1) "row " else "rows ", shown, more)
}

#' One row per patient per assessment of sore throat at rest
#'
#' Missing assessments stay as rows with a missing outcome, so missingness
#' can be counted from this table; the models drop them. Rows are sorted by
#' patient, then assessment, as `geepack` needs each patient's rows together.
#'
#' @param clean Output of `clean_raw()`.
#' @return Data frame with `patient_id`, `treatment`, `assessment` (factor in
#'   time order), `throat_pain` (0 to 10) and `sore_throat` (1 if the score
#'   is above zero, D-001).
assessments_long <- function(clean) {
  assessments <- c(
    throat_pain_pacu30 = "PACU 30 min",
    throat_pain_pacu90 = "PACU 90 min",
    throat_pain_4h = "4 h after surgery",
    throat_pain_pod1 = "First postoperative morning"
  )
  long <- do.call(rbind, lapply(names(assessments), function(col) {
    data.frame(
      patient_id = clean$patient_id,
      treatment = clean$treatment,
      assessment = assessments[[col]],
      throat_pain = clean[[col]]
    )
  }))
  long$assessment <- factor(long$assessment, levels = unname(assessments))
  long$sore_throat <- as.integer(long$throat_pain > 0)
  long <- long[order(long$patient_id, long$assessment), ]
  rownames(long) <- NULL
  long
}

#' Recode a numeric column to a factor, refusing codes the codebook lacks
#'
#' `factor()` silently turns an unexpected code into NA. That is how a
#' miscoded value disappears from an analysis, so this errors instead.
recode_factor <- function(x, levels, labels = levels, name = "x") {
  bad <- which(!is.na(x) & !x %in% levels)
  if (length(bad) > 0) {
    stop(
      sprintf(
        "Column '%s' has codes not in the codebook: %s (%s)",
        name, paste(sort(unique(x[bad])), collapse = ", "), fmt_rows(bad)
      ),
      call. = FALSE
    )
  }
  factor(x, levels = levels, labels = labels)
}
