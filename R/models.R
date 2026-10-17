# Model fitting and effect extraction. Every model function added here needs
# a simulation-recovery test (CLAUDE.md rule 8).

#' Odds ratio with Wald 95% CI for one coefficient of a glm, glmer or
#' geeglm fit
odds_ratio <- function(fit, term) {
  est <- stats::coef(summary(fit))
  if (!term %in% rownames(est)) {
    stop("Term '", term, "' not in model", call. = FALSE)
  }
  se_col <- intersect(c("Std. Error", "Std.err"), colnames(est))[1]
  b <- est[term, "Estimate"]
  se <- est[term, se_col]
  z <- b / se
  data.frame(
    term = term,
    log_or = b,
    se = se,
    or = exp(b),
    lower = exp(b - stats::qnorm(0.975) * se),
    upper = exp(b + stats::qnorm(0.975) * se),
    p_value = 2 * stats::pnorm(-abs(z)),
    n_obs = length(stats::fitted(fit))
  )
}

# The treatment coefficient in every model: licorice against sugar water
treatment_term <- "treatmentLicorice"

#' Proportions by arm and risk difference with a Wald 95% CI (D-006, D-017)
#'
#' @param y 0/1 outcome; missing values are dropped (complete case).
#' @param treatment Factor with levels "Sugar water" and "Licorice".
#' @return One-row data frame; `rd` is licorice minus sugar water.
risk_difference <- function(y, treatment) {
  observed <- !is.na(y)
  y <- y[observed]
  licorice <- treatment[observed] == "Licorice"
  n1 <- sum(licorice)
  n0 <- sum(!licorice)
  p1 <- mean(y[licorice])
  p0 <- mean(y[!licorice])
  rd <- p1 - p0
  se <- sqrt(p1 * (1 - p1) / n1 + p0 * (1 - p0) / n0)
  data.frame(
    n_sugar = n0, n_licorice = n1, p_sugar = p0, p_licorice = p1,
    rd = rd,
    rd_lower = rd - stats::qnorm(0.975) * se,
    rd_upper = rd + stats::qnorm(0.975) * se
  )
}

#' Unadjusted logistic regression at one assessment: the marginal odds ratio
#'
#' With treatment the only term, its odds ratio is the marginal odds ratio
#' (D-007). Patients not observed at this assessment are left out.
#'
#' @param long Output of `assessments_long()`.
#' @param assessment One level of `long$assessment`.
#' @return One row: the odds ratio from `odds_ratio()` and the risk
#'   difference from `risk_difference()`.
fit_assessment <- function(long, assessment) {
  d <- long[long$assessment == assessment & !is.na(long$sore_throat), ]
  fit <- stats::glm(sore_throat ~ treatment, family = stats::binomial(), data = d)
  cbind(
    data.frame(assessment = assessment),
    odds_ratio(fit, treatment_term),
    risk_difference(d$sore_throat, d$treatment)
  )
}

#' Common marginal odds ratio across assessments, from an exchangeable GEE
#'
#' Treatment and assessment (a factor), no interaction, so it assumes one
#' common effect (D-014). Robust (sandwich) standard errors (D-007).
#'
#' @param long Output of `assessments_long()`, sorted by patient.
#' @return One row from `odds_ratio()`, plus the number of patients and the
#'   estimated exchangeable working correlation.
fit_gee_common <- function(long) {
  d <- long[!is.na(long$sore_throat), ]
  fit <- geepack::geeglm(
    sore_throat ~ treatment + assessment,
    family = stats::binomial(), data = d,
    id = patient_id, corstr = "exchangeable", std.err = "san.se"
  )
  # An independence fit has no correlation parameter; NA makes that visible
  alpha <- fit$geese$alpha
  cbind(
    odds_ratio(fit, treatment_term),
    n_patients = length(unique(d$patient_id)),
    working_correlation = if (length(alpha) == 1) unname(alpha) else NA_real_
  )
}

#' Common conditional (patient-level) odds ratio, from a mixed model
#'
#' Random intercept per patient (D-008). The odds ratio compares the same
#' patient under each gargle; it is not the marginal odds ratio.
#'
#' @param long Output of `assessments_long()`.
#' @param n_agq Adaptive Gauss-Hermite quadrature points for the random
#'   intercept. With four binary outcomes per patient, the Laplace
#'   approximation (1) underestimated the patient SD and raised convergence
#'   warnings in simulation; 9 did neither (D-020).
#' @return One row from `odds_ratio()`, plus the number of patients and the
#'   estimated standard deviation of the random intercept.
fit_glmm_common <- function(long, n_agq = 9) {
  d <- long[!is.na(long$sore_throat), ]
  fit <- lme4::glmer(
    sore_throat ~ treatment + assessment + (1 | patient_id),
    family = stats::binomial(), data = d, nAGQ = n_agq
  )
  cbind(
    odds_ratio(fit, treatment_term),
    n_patients = length(unique(d$patient_id)),
    sd_patient = attr(lme4::VarCorr(fit)$patient_id, "stddev")[[1]]
  )
}

#' Merge factor levels with fewer than `min_n` patients into a neighbour
#'
#' The smallest sparse level merges into the adjacent level with fewer
#' patients (the earlier one on a tie), and this repeats until every level has
#' `min_n` patients or one level is left (D-016). Counts are baseline counts.
merge_sparse_levels <- function(x, min_n = 10) {
  x <- droplevels(x)
  repeat {
    counts <- table(x)
    if (length(counts) < 2 || min(counts) >= min_n) return(x)
    i <- which.min(counts)
    neighbours <- intersect(c(i - 1, i + 1), seq_along(counts))
    j <- neighbours[which.min(counts[neighbours])]
    merged <- paste(names(counts)[sort(c(i, j))], collapse = "/")
    new_levels <- names(counts)
    new_levels[c(i, j)] <- merged
    levels(x) <- new_levels
  }
}

#' Data and covariates for the adjusted sensitivity analysis (D-009, D-011)
#'
#' Sparse categories are merged from baseline counts in all patients
#' (D-016). A covariate left with one level is dropped. For preoperative
#' sore throat this is the rule in D-011: it is left out when fewer than
#' `min_n` patients have one.
#'
#' @param clean Output of `clean_raw()`.
#' @return List: `data` (one row per patient, `sore_throat` the primary
#'   outcome) and `covariates` (the names entering the model).
adjusted_model_data <- function(clean, min_n = 10) {
  factors <- c("sex", "asa", "smoking", "surgery_size", "preop_sore_throat")
  d <- clean[, c("patient_id", "treatment", "age", "bmi", factors)]
  d$sore_throat <- any_sore_throat(clean$throat_pain_pacu30)
  for (v in factors) d[[v]] <- merge_sparse_levels(d[[v]], min_n)
  kept <- factors[vapply(d[factors], nlevels, integer(1)) > 1]
  list(data = d, covariates = c("age", "bmi", kept))
}

#' Covariate-adjusted logistic regression of the primary outcome
#'
#' The odds ratio is conditional on the covariates, so it differs from the
#' unadjusted one even with perfect balance (D-009). Age and BMI are linear.
#'
#' @param clean Output of `clean_raw()`.
#' @return One row from `odds_ratio()`, plus the covariates used.
fit_adjusted <- function(clean, min_n = 10) {
  model <- adjusted_model_data(clean, min_n)
  formula <- stats::reformulate(c("treatment", model$covariates), "sore_throat")
  fit <- stats::glm(formula, family = stats::binomial(), data = model$data)
  cbind(
    odds_ratio(fit, treatment_term),
    covariates = paste(model$covariates, collapse = ", ")
  )
}

#' Best- and worst-case bounds for the primary odds ratio (D-010)
#'
#' Refits the primary model with every missing outcome filled in: best case
#' for licorice sets missing licorice outcomes to no sore throat and missing
#' sugar-water outcomes to sore throat; worst case is the reverse.
#'
#' @param y 0/1 primary outcome with missing values.
#' @param treatment Factor with levels "Sugar water" and "Licorice".
#' @return Two rows from `odds_ratio()`, labeled by `bound`, with the number
#'   of outcomes filled in.
missing_bounds <- function(y, treatment) {
  licorice <- treatment == "Licorice"
  fill <- function(y_licorice, y_sugar) {
    y[is.na(y) & licorice] <- y_licorice
    y[is.na(y) & !licorice] <- y_sugar
    fit <- stats::glm(y ~ treatment, family = stats::binomial())
    odds_ratio(fit, treatment_term)
  }
  cbind(
    bound = c("Best case for licorice", "Worst case for licorice"),
    rbind(fill(0, 1), fill(1, 0)),
    n_filled = sum(is.na(y))
  )
}
