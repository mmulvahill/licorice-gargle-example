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
