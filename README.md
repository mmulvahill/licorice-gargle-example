# reproducible-analysis-starter

A project template for statistical consulting work that stays
reproducible and checkable when an AI assistant writes much of the code.
This repo is the empty starting point. To see every piece in use first,
look at the completed worked example, a reanalysis of a public randomized
trial:

- **Example repo:** [licorice-gargle-example](https://github.com/mmulvahill/licorice-gargle-example)
  (also on this repo's [`example`](https://github.com/mmulvahill/reproducible-analysis-starter/tree/example) branch)
- **Example report:** https://mmulvahill.github.io/licorice-gargle-example/

## What is in it

| Piece | Where | Why |
|---|---|---|
| Lab notebook + client report in one | Quarto book: `index.qmd`, `chapters/` | Plan, results and record live together and render from code |
| No typed numbers | `scripts/check_inline_numbers.R` | Every number in the prose comes from inline R, so text cannot drift from results |
| Decision record | `DECISIONS.md` | Every choice that could change a result, with reasons and alternatives |
| Research log | `RESEARCH_LOG.md` | Append-only record of what happened and what it changed |
| Read-only raw data | `data/raw/` + checksum in `scripts/02_make_analysis_data.R` | Received data is never edited; all cleaning is code |
| Functions in a package | `R/`, `DESCRIPTION` | One home for every function the report uses |
| Models fitted once | `scripts/03_fit_models.R`, `R/results.R` | Every estimate is computed in one place and saved; chapters only format it, so the summary and the chapters cannot disagree |
| Tests | `tests/testthat/` | Known-answer tests on tiny hand-built data; simulation-recovery tests for every model |
| Lint + pre-commit | `.lintr`, `.pre-commit-config.yaml` | Machines check style so review time goes to substance |
| CI and publishing | `.github/workflows/` | Every push to `main` and every pull request is checked; the book on GitHub Pages always matches the code |
| Instructions for Claude | `CLAUDE.md`, `.claude/` | Your standards, written once, read every session, partly enforced by hooks |

## Quick start

You need R (4.1 or later), [Quarto](https://quarto.org/docs/get-started/),
and the packages listed in `DESCRIPTION`:

```r
install.packages(c("ggplot2", "here", "knitr", "lintr", "pkgload",
                   "rmarkdown", "testthat"))
```

Then, from the repo root:

```bash
make all            # or, without make (e.g. Windows): Rscript run_all.R
```

Open `_book/index.html`. Until data arrives, `make data` and
`make results` skip, and the book renders the plan with an "Awaiting data"
note.

## Using it with Claude Code

Open the folder and run `claude`. Claude Code reads `CLAUDE.md`
automatically. The project also sets up:

- **Skills:** `/log-decision`, `/log-research`, and `/review-analysis` (run
  the review in a *fresh* session so the reviewer did not write the work).
- **A hook** that runs the typed-number check after every file edit and shows
  Claude any violation.
- **Permission rules** that block Claude's file tools from editing
  `data/raw/` or reading `data/phi/`. These are guardrails, not a security
  boundary: a shell command could still reach those files. Keep identifiable
  data off any machine or account not approved for it.

## Using it with Claude in a browser

No Claude Code yet? Create a Project on claude.ai and paste `CLAUDE.md` into
its instructions. You lose the hooks and the automatic test runs, so run
`make all` yourself before trusting anything. **Do not paste identifiable
patient data into a personal account.**

## Pinning package versions

`chapters/10-reproducibility.qmd` records `sessionInfo()`, which says what
was used but cannot restore it. For your own project, run `renv::init()`
once, commit `renv.lock`, and have collaborators run `renv::restore()`.

## Starting your own project

Click **Use this template** on GitHub, clone the new repo, open it, and run
`claude`. Then work through it in conversation; each step below is
something you say or type. The full script, from an empty repo to the
completed worked example, is in the example repo's `WALKTHROUGH.md`.

1. *"Rename the package to `<name>` and set the book title and repo URL."*
2. Paste your intake notes (or save them in `notes/`) and run
   `/draft-plan`. Claude restates the question, then works through the
   plan with you one topic at a time and logs each decision.
3. In a **fresh session**, run `/review-plan`. Revise, then commit and tag
   the plan: *"Commit the plan and tag it plan-v1."*
4. When data arrives: `/receive-data <path-to-file> <where it came from>`.
   Check your data agreement before committing data to any remote.
5. *"Write the cleaning function with known-answer tests."* Then, for each
   model: *"Write it with a simulation-recovery test, then break it on
   purpose and show me the test fail."*
6. *"Fit the planned models in `analysis_results()` and write the results
   chapters."*
7. In a **fresh session**, run `/review-analysis`. Fix what matters, with a
   decision entry for each change to the analysis. Write the summary last.
8. To publish the book: Settings → Pages → Source: GitHub Actions. The
   Pages site is public even for a private repo on most GitHub plans.

The example repo has exercises (`EXERCISES.md`) that walk through the
workflow.

## License

MIT.
