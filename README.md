# licorice-gargle-example

A completed analysis built with
[reproducible-analysis-starter](https://github.com/mmulvahill/reproducible-analysis-starter),
the project template for statistical consulting work that stays
reproducible and checkable when an AI assistant writes much of the code.
It reanalyzes a public randomized trial: does a licorice gargle before
intubation reduce postoperative sore throat, and does the effect last?

**Rendered report:** https://mmulvahill.github.io/licorice-gargle-example/

## How it was built

From the empty template, in conversation with Claude Code, starting from an
analyst's scratch notes. [WALKTHROUGH.md](WALKTHROUGH.md) has every prompt,
in order, with what to expect; the git history is the result, step by step.
The plan was locked with the `plan-v1` tag before the data arrived.

| Where | What |
|---|---|
| `notes/` | The intake notes and the PI call, as received |
| `chapters/01-question.qmd`, `03-methods.qmd` | The question and the plan, written before the data |
| `DECISIONS.md`, `RESEARCH_LOG.md` | Every decision with who made it and when; what happened |
| `R/`, `tests/` | Cleaning, models and simulator, with known-answer and simulation-recovery tests |
| `scripts/check_test_breaks.R` | Deliberate breaks of each model, and the tests that catch them |
| `index.qmd`, `chapters/` | The report; every number computed when it renders |

[EXERCISES.md](EXERCISES.md) has short things to try.

## Reproduce it

You need R (4.1 or later), [Quarto](https://quarto.org/docs/get-started/)
and the packages in `DESCRIPTION`. Then `make all` (or `Rscript run_all.R`)
and open `_book/index.html`. The recovery tests take about a minute.

## Starting your own project

Don't copy this repo. Use the empty template,
[reproducible-analysis-starter](https://github.com/mmulvahill/reproducible-analysis-starter):
click **Use this template** there.

## Data

The licorice gargle trial (Ruetzler et al., *Anesth Analg*
2013;117:614–21), as distributed in the
[`medicaldata`](https://github.com/higgi13425/medicaldata) R package (MIT
license), contributed by Amy S. Nowacki. The "client" and the engagement
are fictional; the analysis is real.

## License

MIT.
