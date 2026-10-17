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

test_that("proportion and risk-difference formatters give the expected strings", {
  expect_equal(fmt_prop(c(42 / 116, 0.5), c(116, 10)), c("42 of 116 (36%)", "5 of 10 (50%)"))
  rd <- data.frame(rd = -0.1738, rd_lower = -0.2871, rd_upper = -0.0615)
  expect_equal(fmt_rd(rd), "-17.4 percentage points (95% CI -28.7 to -6.2)")
  expect_equal(fmt_rd_cell(rd$rd, rd$rd_lower, rd$rd_upper), "-17.4 (-28.7 to -6.2)")
})
