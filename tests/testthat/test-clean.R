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
