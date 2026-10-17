# Break each model function on purpose and list the tests that fail.
# Run from the repo root: Rscript scripts/check_test_breaks.R (about 13 min).
#
# Evidence that the tests can fail (CLAUDE.md, step 4). Each break swaps one
# function in the loaded package for a broken copy, runs the model and
# recovery tests, then restores it; no file on disk changes. Every break
# should fail at least one test. A break that passes them all means a test
# needs strengthening. Results are summarised in RESEARCH_LOG.md.
pkgload::load_all(".", quiet = TRUE)
ns <- asNamespace("licorice")

# Each break: function name and either a text substitution in its body or a
# replacement function
breaks <- list(
  "RD sign flipped (sugar minus licorice)" =
    list("risk_difference", "rd <- p1 - p0", "rd <- p0 - p1"),
  "RD SE uses total n" =
    list("risk_difference", "p1 * (1 - p1)/n1", "p1 * (1 - p1)/(n1 + n0)"),
  "Per-time fit pools all assessments" =
    list("fit_assessment", "long$assessment == assessment & ", ""),
  "Odds-ratio CI is 90% not 95%" =
    list("odds_ratio", "stats::qnorm(0.975) * se", "stats::qnorm(0.95) * se"),
  "GEE ignores patients (each row its own cluster)" =
    list("fit_gee_common", "id = patient_id", "id = seq_len(nrow(d))"),
  "GEE independence working correlation" =
    list("fit_gee_common", "\"exchangeable\"", "\"independence\""),
  "Mixed model replaced by logistic regression ignoring patients" =
    list("fit_glmm_common", function(long, n_agq = 9) {
      d <- long[!is.na(long$sore_throat), ]
      fit <- stats::glm(sore_throat ~ treatment + assessment,
                        family = stats::binomial(), data = d)
      # The glm has no patient SD; report the truth so only the OR can fail
      cbind(odds_ratio(fit, treatment_term),
            n_patients = length(unique(d$patient_id)), sd_patient = 1.5)
    }),
  "Mixed model with Laplace (nAGQ = 1)" =
    list("fit_glmm_common", "nAGQ = n_agq", "nAGQ = 1"),
  "Adjusted model drops its covariates" =
    list("fit_adjusted", "c(\"treatment\", model$covariates)", "\"treatment\""),
  "Sparse levels never merged" =
    list("merge_sparse_levels", function(x, min_n = 10) droplevels(x)),
  "Bounds labels swapped" =
    list("missing_bounds", "rbind(fill(0, 1), fill(1, 0))", "rbind(fill(1, 0), fill(0, 1))"),
  "Bounds fill both arms the same way" =
    list("missing_bounds", "y[is.na(y) & !licorice] <- y_sugar",
         "y[is.na(y) & !licorice] <- y_licorice"),
  "Integration uses variance as SD" =
    list("marginal_risk", "stats::dnorm(b, 0, sd)", "stats::dnorm(b, 0, sd^2)")
)

broken_version <- function(original, spec) {
  if (is.function(spec[[1]])) {
    fn <- spec[[1]]
  } else {
    text <- paste(deparse(body(original), width.cutoff = 500), collapse = "\n")
    changed <- sub(spec[[1]], spec[[2]], text, fixed = TRUE)
    if (identical(changed, text)) stop("Break did not apply: ", spec[[1]])
    fn <- original
    body(fn) <- str2lang(changed)
  }
  environment(fn) <- ns
  fn
}

for (label in names(breaks)) {
  b <- breaks[[label]]
  original <- get(b[[1]], envir = ns)
  unlockBinding(b[[1]], ns)
  assign(b[[1]], broken_version(original, b[-1]), envir = ns)
  out <- testthat::test_dir(
    "tests/testthat", filter = "models|recovery", reporter = "silent",
    stop_on_failure = FALSE, load_package = "none", package = "licorice"
  )
  assign(b[[1]], original, envir = ns)
  cat("\n###", label, "\n")
  n_failed <- 0
  for (t in out) {
    for (e in t$results) {
      if (inherits(e, c("expectation_failure", "expectation_error"))) {
        n_failed <- n_failed + 1
        first_line <- strsplit(conditionMessage(e), "\n")[[1]][1]
        cat(sprintf("  %s | %s | %s\n", t$file, t$test, first_line))
      }
    }
  }
  if (n_failed == 0) cat("  NO TEST FAILED\n")
}
