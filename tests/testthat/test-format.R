test_that("formatters produce the strings the report expects", {
  expect_equal(fmt_pct(0.4567), "46%")
  expect_equal(fmt_pct(0.4567, 1), "45.7%")
  expect_equal(fmt_p(0.0004), "p < 0.001")
  expect_equal(fmt_p(0.0432), "p = 0.043")
  row <- data.frame(or = 0.4212, lower = 0.2401, upper = 0.7388)
  expect_equal(fmt_or(row), "OR 0.42, 95% CI 0.24 to 0.74")
  expect_equal(fmt_or_cell(c(0.4212, 2), c(0.2401, 1), c(0.7388, 4)),
               c("0.42 (0.24 to 0.74)", "2.00 (1.00 to 4.00)"))
})
