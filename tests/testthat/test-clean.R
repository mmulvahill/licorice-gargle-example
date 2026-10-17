test_that("recode_factor labels codes exactly as given", {
  out <- recode_factor(c(0, 1, NA, 1), c(0, 1), c("No", "Yes"), "flag")
  expect_equal(as.character(out), c("No", "Yes", NA, "Yes"))
  expect_equal(levels(out), c("No", "Yes"))
})

test_that("an unexpected code errors instead of silently becoming NA", {
  expect_error(
    recode_factor(c(0, 1, 2), c(0, 1), name = "flag"),
    "flag.*not in the codebook: 2"
  )
})

test_that("recode_factor names the rows holding an unexpected code", {
  expect_error(
    recode_factor(c(0, 5, 1, 5), c(0, 1), name = "flag"),
    "rows 2, 4"
  )
})

# A hand-built raw file with the delivered columns, in the delivered order.
# Patient 3 has no post-operative data, like two patients in the real file.
tiny_raw_csv <- paste(
  paste0(
    '"preOp_gender","preOp_asa","preOp_calcBMI","preOp_age","preOp_mallampati",',
    '"preOp_smoking","preOp_pain","treat","intraOp_surgerySize","extubation_cough",',
    '"pacu30min_cough","pacu30min_throatPain","pacu30min_swallowPain",',
    '"pacu90min_cough","pacu90min_throatPain","postOp4hour_cough",',
    '"postOp4hour_throatPain","pod1am_cough","pod1am_throatPain"'
  ),
  "0,3,33.0,67,2,1,0,1,2,0,0,0,0,0,0,0,0,0,0",
  "1,2,23.66,76,2,2,0,1,1,3,0,2,4,0,1,1,0,1,3",
  "1,1,20.5,58,4,3,1,0,3,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA",
  "0,2,26.25,40,1,3,0,0,2,1,1,10,8,0,5,2,4,0,0",
  sep = "\n"
)
tiny_raw <- function() utils::read.csv(text = tiny_raw_csv)

test_that("clean_raw gives one labeled row per patient, with an id", {
  clean <- clean_raw(tiny_raw())
  expect_equal(nrow(clean), 4)
  expect_equal(clean$patient_id, 1:4)
  expect_equal(as.character(clean$treatment),
               c("Licorice", "Licorice", "Sugar water", "Sugar water"))
  # Sugar water is the reference, so odds ratios are licorice vs sugar water
  expect_equal(levels(clean$treatment), c("Sugar water", "Licorice"))
  expect_equal(as.character(clean$sex), c("Male", "Female", "Female", "Male"))
  expect_equal(as.character(clean$asa), c("III", "II", "I", "II"))
  expect_equal(as.character(clean$mallampati), c("II", "II", "IV", "I"))
  expect_equal(as.character(clean$smoking), c("Current", "Past", "Never", "Never"))
  expect_equal(as.character(clean$preop_sore_throat), c("No", "No", "Yes", "No"))
  expect_equal(as.character(clean$surgery_size), c("Medium", "Small", "Large", "Medium"))
  expect_equal(clean$age, c(67, 76, 58, 40))
  expect_equal(clean$bmi, c(33.0, 23.66, 20.5, 26.25))
  expect_equal(clean$throat_pain_pacu30, c(0, 2, NA, 10))
  expect_equal(clean$swallow_pain_pacu30, c(0, 4, NA, 8))
  expect_equal(clean$throat_pain_pacu90, c(0, 1, NA, 5))
  expect_equal(clean$throat_pain_4h, c(0, 0, NA, 4))
  expect_equal(clean$throat_pain_pod1, c(0, 3, NA, 0))
  expect_equal(clean$cough_extubation, c(0, 3, NA, 1))
  expect_equal(clean$cough_pod1, c(0, 1, NA, 0))
})

test_that("an unexpected code stops cleaning, naming the column and row", {
  raw <- tiny_raw()
  raw$treat[3] <- 2
  expect_error(clean_raw(raw), "treat.*not in the codebook: 2.*row 3")
})

test_that("an out-of-range score stops cleaning, naming the column and row", {
  raw <- tiny_raw()
  raw$pod1am_throatPain[2] <- 11
  expect_error(clean_raw(raw), "pod1am_throatPain.*0 to 10.*row 2")
  raw <- tiny_raw()
  raw$pacu90min_cough[4] <- 4
  expect_error(clean_raw(raw), "pacu90min_cough.*0 to 3.*row 4")
})

test_that("a fractional score stops cleaning", {
  raw <- tiny_raw()
  raw$pacu30min_throatPain[1] <- 2.5
  expect_error(clean_raw(raw), "pacu30min_throatPain.*whole numbers.*row 1")
})

test_that("an implausible age or BMI stops cleaning", {
  raw <- tiny_raw()
  raw$preOp_age[4] <- 400
  expect_error(clean_raw(raw), "preOp_age.*row 4")
  raw <- tiny_raw()
  raw$preOp_calcBMI[1] <- 0
  expect_error(clean_raw(raw), "preOp_calcBMI.*row 1")
})

test_that("text in a numeric column stops cleaning instead of becoming NA", {
  raw <- tiny_raw()
  raw$pacu30min_throatPain <- as.character(raw$pacu30min_throatPain)
  raw$pacu30min_throatPain[2] <- "n/a"
  expect_error(clean_raw(raw), "pacu30min_throatPain.*not a number.*row 2")
})

test_that("a missing treatment stops cleaning", {
  raw <- tiny_raw()
  raw$treat[1] <- NA
  expect_error(clean_raw(raw), "treat.*missing.*row 1")
})

test_that("a missing or unexpected column stops cleaning", {
  raw <- tiny_raw()
  raw$preOp_asa <- NULL
  expect_error(clean_raw(raw), "missing.*preOp_asa")
  raw <- tiny_raw()
  raw$study_site <- 1
  expect_error(clean_raw(raw), "not in the codebook.*study_site")
})

test_that("every problem is reported at once, not just the first", {
  raw <- tiny_raw()
  raw$treat[3] <- 2
  raw$pod1am_throatPain[2] <- 11
  expect_error(clean_raw(raw), "treat.*pod1am_throatPain")
})

test_that("assessments_long has one row per patient per assessment", {
  long <- assessments_long(clean_raw(tiny_raw()))
  expect_equal(nrow(long), 16)
  expect_equal(long$patient_id, rep(1:4, each = 4))
  expect_equal(
    levels(long$assessment),
    c("PACU 30 min", "PACU 90 min", "4 h after surgery", "First postoperative morning")
  )
  expect_equal(as.integer(long$assessment), rep(1:4, times = 4))
  expect_equal(as.character(long$treatment), rep(c("Licorice", "Sugar water"), each = 8))
  # Patient 2: scores 2, 1, 0, 3 at the four assessments
  expect_equal(long$throat_pain[long$patient_id == 2], c(2, 1, 0, 3))
  expect_equal(long$sore_throat[long$patient_id == 2], c(1, 1, 0, 1))
  # Patient 4: 10, 5, 4, 0
  expect_equal(long$sore_throat[long$patient_id == 4], c(1, 1, 1, 0))
  # Missing assessments are kept as rows with a missing outcome
  expect_true(all(is.na(long$sore_throat[long$patient_id == 3])))
})
