test_that("odds_ratio matches the textbook 2x2 calculation for a glm", {
  # 2x2: A 30/50 with the outcome, B 15/50. OR = (15/35) / (30/20).
  d <- data.frame(
    arm = factor(rep(c("A", "B"), each = 50)),
    y = c(rep(1, 30), rep(0, 20), rep(1, 15), rep(0, 35))
  )
  fit <- stats::glm(y ~ arm, family = stats::binomial(), data = d)
  est <- odds_ratio(fit, "armB")
  expect_equal(est$or, (15 / 35) / (30 / 20), tolerance = 1e-6)
  expect_equal(est$n_obs, 100)
  # Woolf SE of the log OR, and a 95% Wald interval: z = 1.959964
  se <- sqrt(1 / 30 + 1 / 20 + 1 / 15 + 1 / 35)
  expect_equal(est$se, se, tolerance = 1e-6)
  expect_equal(est$lower, est$or * exp(-1.959964 * se), tolerance = 1e-6)
  expect_equal(est$upper, est$or * exp(1.959964 * se), tolerance = 1e-6)
  # glm converges to about 1e-9, which a tail probability magnifies
  expect_equal(est$p_value, 2 * stats::pnorm(-abs(log(est$or) / se)), tolerance = 1e-4)
})

test_that("odds_ratio refuses a term that is not in the model", {
  d <- data.frame(arm = factor(c("A", "B", "A", "B")), y = c(1, 0, 0, 1))
  fit <- stats::glm(y ~ arm, family = stats::binomial(), data = d)
  expect_error(odds_ratio(fit, "age"), "not in model")
})

arms <- function(n_sugar, n_licorice) {
  factor(
    rep(c("Sugar water", "Licorice"), c(n_sugar, n_licorice)),
    levels = c("Sugar water", "Licorice")
  )
}

test_that("risk_difference matches the hand-computed Wald interval", {
  # Sugar water 30/50, licorice 15/50, plus missing outcomes that are dropped.
  # The RD is 0.3 minus 0.6, and its variance is 0.0042 + 0.0048 = 0.009
  y <- c(rep(1, 30), rep(0, 20), NA, rep(1, 15), rep(0, 35), NA, NA)
  rd <- risk_difference(y, arms(51, 52))
  expect_equal(c(rd$n_sugar, rd$n_licorice), c(50, 50))
  expect_equal(c(rd$p_sugar, rd$p_licorice), c(0.6, 0.3))
  expect_equal(rd$rd, -0.3)
  expect_equal(rd$rd_lower, -0.3 - 1.959964 * sqrt(0.009), tolerance = 1e-6)
  expect_equal(rd$rd_upper, -0.3 + 1.959964 * sqrt(0.009), tolerance = 1e-6)
})

test_that("missing_bounds fills in missing outcomes the right way round", {
  # Sugar water: 6 yes, 4 no, 2 missing. Licorice: 3 yes, 7 no, 1 missing.
  y <- c(rep(1, 6), rep(0, 4), NA, NA, rep(1, 3), rep(0, 7), NA)
  bounds <- missing_bounds(y, arms(12, 11))
  expect_equal(bounds$bound, c("Best case for licorice", "Worst case for licorice"))
  # Best: licorice 3 yes / 8 no, sugar water 8 yes / 4 no
  expect_equal(bounds$or[1], (3 / 8) / (8 / 4), tolerance = 1e-6)
  # Worst: licorice 4 yes / 7 no, sugar water 6 yes / 6 no
  expect_equal(bounds$or[2], (4 / 7) / (6 / 6), tolerance = 1e-6)
  expect_equal(bounds$n_filled, c(3, 3))
  expect_equal(bounds$n_obs, c(23, 23))
})

test_that("absent_worst_case adds absent patients to licorice with sore throat", {
  # The same data as above; the worst case is licorice 4 yes / 7 no, sugar
  # water 6 yes / 6 no. One absent patient makes licorice 5 yes / 7 no.
  y <- c(rep(1, 6), rep(0, 4), NA, NA, rep(1, 3), rep(0, 7), NA)
  extended <- absent_worst_case(y, arms(12, 11), n_absent = 1)
  expect_equal(extended$or, (5 / 7) / (6 / 6), tolerance = 1e-6)
  expect_equal(c(extended$n_filled, extended$n_absent, extended$n_obs), c(3, 1, 24))
  # With nobody absent it is the worst case of missing_bounds()
  none <- absent_worst_case(y, arms(12, 11), n_absent = 0)
  expect_equal(none$or, missing_bounds(y, arms(12, 11))$or[2], tolerance = 1e-8)
  expect_error(absent_worst_case(y, arms(12, 11), n_absent = -1), "more patients")
})

test_that("fit_assessment uses only the named assessment's observed rows", {
  long <- data.frame(
    patient_id = rep(1:8, each = 2),
    treatment = rep(arms(4, 4), each = 2),
    assessment = factor(rep(c("A", "B"), 8)),
    sore_throat = c(1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, NA, 0, 1, 0, 1)
  )
  est <- fit_assessment(long, "A")
  # At A: sugar water 3/4, licorice 1/4. OR = (1/3) / (3/1)
  expect_equal(est$or, (1 / 3) / 3, tolerance = 1e-6)
  expect_equal(est$rd, 0.25 - 0.75)
  # At B one licorice outcome is missing: sugar water 2/4, licorice 2/3
  est <- fit_assessment(long, "B")
  expect_equal(c(est$n_sugar, est$n_licorice), c(4, 3))
  expect_equal(est$or, (2 / 1) / (2 / 2), tolerance = 1e-6)
})

test_that("merge_sparse_levels merges into the smaller neighbour", {
  f <- function(counts) factor(rep(names(counts), counts), levels = names(counts))
  merged <- function(counts) c(table(merge_sparse_levels(f(counts))))
  expect_equal(merged(c(I = 3, II = 20, III = 15)), c("I/II" = 23, III = 15))
  expect_equal(merged(c(A = 30, B = 4, C = 12)), c(A = 30, "B/C" = 16))
  expect_equal(merged(c(A = 12, B = 2, C = 12)), c("A/B" = 14, C = 12))
  # A cascade: A merges into B, and the result is still sparse
  expect_equal(merged(c(A = 3, B = 4, C = 30)), c("A/B/C" = 37))
  expect_equal(merged(c(No = 233, Yes = 2)), c("No/Yes" = 235))
  expect_equal(merged(c(A = 10, B = 10)), c(A = 10, B = 10))
  # An empty level is dropped rather than merged
  expect_equal(merged(c(A = 0, B = 12, C = 15)), c(B = 12, C = 15))
})

test_that("preoperative sore throat enters the adjusted model only with 10 patients", {
  set.seed(11)
  coef <- c(
    intercept = 0, licorice = 0, female = 0, age = 0, bmi = 0, asa_ii = 0,
    asa_iii = 0, smoking_past = 0, smoking_never = 0, surgery_medium = 0,
    surgery_large = 0, preop_yes = 0
  )
  d <- simulate_baseline_trial(coef, n = 100)
  d$preop_sore_throat[] <- "No"
  d$preop_sore_throat[1:9] <- "Yes"
  expect_equal(
    adjusted_model_data(d)$covariates,
    c("age", "bmi", "sex", "asa", "smoking", "surgery_size")
  )
  d$preop_sore_throat[10] <- "Yes"
  expect_true("preop_sore_throat" %in% adjusted_model_data(d)$covariates)
  # A sparse ASA class is merged before fitting
  d$asa[] <- "II"
  d$asa[1:5] <- "I"
  d$asa[6:40] <- "III"
  expect_equal(levels(adjusted_model_data(d)$data$asa), c("I/II", "III"))
  expect_match(fit_adjusted(d)$covariates, "asa")
  # Only covariates still in the model are reported as merged
  expect_true("asa" %in% merged_covariates(adjusted_model_data(d)))
  expect_false("sex" %in% merged_covariates(adjusted_model_data(d)))
  d$preop_sore_throat[] <- "No"
  d$preop_sore_throat[1:2] <- "Yes"
  expect_false("preop_sore_throat" %in% merged_covariates(adjusted_model_data(d)))
})

test_that("marginal_risk integrates the random intercept correctly", {
  expect_equal(marginal_risk(0.7, 0), stats::plogis(0.7))
  # Symmetry: at eta = 0 the marginal risk is one half for any SD
  expect_equal(marginal_risk(0, 2), 0.5, tolerance = 1e-8)
  set.seed(3)
  b <- stats::rnorm(1e6, 0, 1.5)
  expect_equal(marginal_risk(c(-1, 0.8), 1.5),
               c(mean(stats::plogis(-1 + b)), mean(stats::plogis(0.8 + b))),
               tolerance = 2e-3)
  # A random intercept pulls the marginal risk toward one half
  expect_lt(marginal_risk(2, 1.5), stats::plogis(2))
})

test_that("within_patient_correlation matches a simulated correlation", {
  set.seed(4)
  eta <- c(0.8, -1)
  b <- stats::rnorm(4e5, 0, 1.5)
  y1 <- stats::rbinom(4e5, 1, stats::plogis(eta[1] + b))
  y2 <- stats::rbinom(4e5, 1, stats::plogis(eta[2] + b))
  expect_equal(within_patient_correlation(eta, 1.5), stats::cor(y1, y2),
               tolerance = 0.01)
})

test_that("licorice_eta_for_marginal_or gives the same marginal OR at each time", {
  eta <- c(0.8, 0.3, -0.2, -1)
  lic <- licorice_eta_for_marginal_or(eta, 0.5, 1.5)
  expect_equal(marginal_or(eta, lic, 1.5), rep(0.5, 4), tolerance = 1e-8)
  # ...which needs a conditional effect that changes over time
  expect_gt(diff(range(lic - eta)), 0.01)
})
