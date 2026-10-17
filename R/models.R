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
