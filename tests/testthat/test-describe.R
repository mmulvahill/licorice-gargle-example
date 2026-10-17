toy <- data.frame(
  arm = factor(c("A", "A", "B", "B")),
  age = c(40, 60, 30, 50),
  sex = factor(c("F", "M", "F", "F"))
)

test_that("table_one matches hand-computed means, SDs and percentages", {
  t1 <- table_one(toy, by = "arm", vars = c("age", "sex"))
  # A: mean 50, SD 14.1; B: mean 40, SD 14.1
  expect_equal(t1$A[t1$variable == "age"], "50.0 (14.1)")
  expect_equal(t1$B[t1$variable == "age"], "40.0 (14.1)")
  expect_equal(t1$A[t1$level == "F"], "1 (50.0%)")
  expect_equal(t1$B[t1$level == "F"], "2 (100.0%)")
})

test_that("missing_by_arm counts missing outcomes by assessment and arm", {
  long <- data.frame(
    patient_id = rep(1:5, each = 2),
    treatment = factor(
      rep(c("Sugar water", "Sugar water", "Licorice", "Licorice", "Licorice"), each = 2),
      levels = c("Sugar water", "Licorice")
    ),
    assessment = factor(rep(c("A", "B"), 5), levels = c("A", "B")),
    sore_throat = c(1, NA, 0, 0, NA, NA, 1, 0, 0, NA)
  )
  m <- missing_by_arm(long)
  expect_equal(m$assessment, c("A", "B"))
  expect_equal(m$n_sugar, c(2, 2))
  expect_equal(m$missing_sugar, c(0, 1))
  expect_equal(m$n_licorice, c(3, 3))
  expect_equal(m$missing_licorice, c(1, 2))
  expect_equal(m$prop_missing, c(1 / 5, 3 / 5))
})
