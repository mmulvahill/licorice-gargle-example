# A simulated stand-in for clean_raw() output, with every column the results
# list uses, so analysis_results() can be tested without the trial data.
# Patients 1 and 2 have no post-operative data, as in the delivered file.
simulate_clean <- function(n = 235) {
  no_effect <- c(
    intercept = 0, licorice = 0, female = 0, age = 0, bmi = 0, asa_ii = 0,
    asa_iii = 0, smoking_past = 0, smoking_never = 0, surgery_medium = 0,
    surgery_large = 0, preop_yes = 0
  )
  d <- simulate_baseline_trial(no_effect, n = n, p_preop = 0.05, n_missing = 0)
  d$mallampati <- factor(
    sample(c("I", "II", "III", "IV"), n, replace = TRUE, prob = c(0.3, 0.57, 0.12, 0.01)),
    levels = c("I", "II", "III", "IV")
  )
  b <- stats::rnorm(n, 0, 1.5)
  eta <- c(0.8, 0.3, -0.2, -1) # sugar water, at each assessment
  licorice <- d$treatment == "Licorice"
  for (i in seq_along(assessment_labels())) {
    sore <- stats::rbinom(n, 1, stats::plogis(eta[i] + log(0.4) * licorice + b))
    d[[names(assessment_labels())[i]]] <- sore * sample(1:10, n, replace = TRUE)
  }
  d[1:2, names(assessment_labels())] <- NA
  d
}
