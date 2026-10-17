# CLAUDE.md

Instructions for Claude Code in this repository. Read this first; it is the
standard of work for the project, written for an AI assistant and a new
analyst alike.

## What this project is

A statistical consulting analysis. The Quarto book is both the lab notebook
and the client report.

```
data/raw/        received data. READ-ONLY. Never edit, never overwrite.
data/derived/    built by `make data` and `make results`. Not committed.
R/               every function the analysis uses (an R package)
tests/testthat/  tests for those functions
scripts/         numbered pipeline scripts (02 data, 03 models) and checks
chapters/        the Quarto book; index.qmd is the summary
notes/           intake and meeting notes, as received. Never edited.
DECISIONS.md     every analysis decision, with reasons
RESEARCH_LOG.md  append-only log of what happened and what we learned
```

## How a project goes

The analyst and Claude work each step out in conversation; Claude drafts,
the analyst decides.

1. **Intake.** The analyst pastes or saves notes in `notes/` and runs
   `/draft-plan`. Together we write the question (Chapter 1) and the plan
   (Chapter 3), logging each decision as it is made.
2. **Attack the plan.** `/review-plan` in a *fresh* session. Revise, then
   lock the plan: commit it and tag it (`git tag plan-v1`). The tag is the
   record that the plan came before the results.
3. **Data.** `/receive-data <file>` records the checksum and checks the
   structure against the plan. Cleaning code in `R/` with known-answer
   tests.
4. **Models.** Each model function gets a simulation-recovery test before
   it touches the real data. Break the code on purpose to check the tests
   can fail.
5. **Results.** Fit everything in `analysis_results()`, then write the
   results chapters from the computed numbers.
6. **Review.** `/review-analysis` in a *fresh* session. Each fix that
   changes the analysis gets a decision entry with its timing.
7. **Summary and publish.** `index.qmd` last; push to `main` to publish.

## Commands

```bash
make data      # raw -> derived (refuses if raw data changed)
make results   # fit every model once -> data/derived/results.rds
make test      # unit tests, known-answer tests, simulation recovery
make lint      # lintr over R/, tests/, scripts/, chapters/
make numbers   # refuses typed numbers in report prose
make book      # render the Quarto book to _book/
make all       # everything above, in order
```

## Rules

1. **Never type a number into report prose.** Every number in a `.qmd`
   comes from inline R, e.g. `` `r fmt_pct(x)` ``. `make numbers` enforces
   this, and a hook runs it after every edit. Never get past the check by
   marking a line `numbers-ok` or by wrapping a typed literal in inline R;
   compute the number, or ask.
2. **Raw data is read-only.** All changes happen in code, from raw to
   derived. A new delivery is a new file plus a DECISIONS.md entry.
3. **Logic lives in `R/`, with tests. Fit each model once.** Every model is
   fitted in `analysis_results()` (`R/results.R`), run by `make results`.
   Chapters and `index.qmd` read `results` and format it; they never fit
   models or define them inline.
4. **Plan before results; prose after numbers.** Until the plan is tagged,
   read only column names, codes and baseline structure, never outcome
   values. Never describe a result you have not computed in this session.
5. **Log decisions.** Any choice about outcomes, models, exclusions,
   covariates or missing data gets a DECISIONS.md entry (`/log-decision`).
   Notable findings and surprises go in RESEARCH_LOG.md (`/log-research`).
6. **Ask before changing the plan.** The primary outcome, primary model and
   estimands in `chapters/03-methods.qmd` are the PI's decisions. Propose;
   do not change them silently. Once the plan is tagged, every change to it
   gets a decision entry; if results have been seen, it is post hoc.
7. **Verify, then claim.** Run `make all` before saying work is done, and
   report what actually passed. Never say tests pass without running them.
8. **New model function → simulation-recovery test.** It must recover a
   known effect from simulated data with the same structure.
9. **Bug fix → a test that fails without the fix.** Revert the fix, show the
   test failing, restore it. Never delete or weaken a test to make a change
   pass; if a test fixture needs a new column, add it.
10. **Never put words in anyone's mouth.** Quote the client only from
    `notes/`, verbatim. A choice the analyst has not confirmed is written as
    *Proposed:* or as an open question, never as a decision.
11. **No identifiable data.** Never read `data/phi/`. Work with synthetic or
    de-identified data unless the project's data agreement allows otherwise.

## Statistical conventions

- Report effect sizes with 95% CIs; p-values to three decimals.
- Name the estimand: conditional (mixed model) vs marginal (GEE) odds
  ratios answer different questions.
- Randomized comparisons: unadjusted primary analysis, adjusted as
  sensitivity. Do not choose covariates by looking at Table 1.
- Warnings from model fits are findings. Do not suppress them.

## Style

tidyverse style, snake_case, lines under 100 characters. Comments say why,
not what.
