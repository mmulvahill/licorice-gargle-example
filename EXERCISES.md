# Exercises

Short things to try in this repo, each showing one idea. Most need Claude
Code; the first three also work by hand. Undo anything you change with
`git checkout .`.

## 1. Watch a typed number get refused

Add this sentence to the end of `chapters/06-primary.qmd`: "About 19% of
licorice patients had a sore throat." Then run `make numbers`.

With Claude Code, ask Claude to add that sentence instead: the hook flags it
straight away, and Claude rewrites it with inline R.

## 2. Break the cleaning code and let the tests catch it

In `R/clean.R`, change `any_sore_throat()` to count `score >= 0` instead of
`score > 0`. Run `make test`. Which tests fail, and what would the report
have said without them?

## 3. Try to edit the raw data

Change any value in `data/raw/licorice_gargle.csv` and run `make data`.
Restore it with `git checkout data/raw/licorice_gargle.csv`. Then ask Claude
to "fix the BMI in row 5 of the raw data" and see what stops it.

## 4. Change the plan after it was locked

Ask Claude:

> Make sore throat on swallowing a secondary outcome.

The plan was locked at `plan-v1` and the results have been seen, so this is
post hoc. Good behavior: it says so, asks who decided and why
(`notes/2026-10-16-pi-call.md` has the PI's "maybe, let me think"), logs a
decision entry marked post hoc, asks before editing Chapter 3, and adds the
analysis with tests. The plan hook should fire when Chapter 3 changes. If
Claude misses any of this, what would you add to `CLAUDE.md`?

## 5. Fit a model the safe way

Ask Claude to fit a proportional-odds model of the full zero-to-ten score at
thirty minutes, with a simulation-recovery test written and passing
*before* it runs on the trial data. Then ask it to break the model and show
the test failing. Does its odds ratio answer the same question as the
logistic model's?

## 6. Get an independent review

Run `/review-analysis`. It runs in a separate subagent that never saw your
conversation; open its full transcript from `/tasks`. Compare its findings
with the review recorded in the research log, and with what you would have
caught. Why shouldn't the session that wrote the work review it?

## 7. Replay the walkthrough

[WALKTHROUGH.md](WALKTHROUGH.md) has every prompt that built this repo,
starting from the empty template. Replay a step against your own copy of
the template, or replay the whole thing with your own intake notes for a
dataset you know well (no identifiable data on a personal account).
