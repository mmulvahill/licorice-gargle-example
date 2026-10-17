# Walkthrough: from an empty template to this analysis

Every step below is something the analyst types into Claude Code. Each
was run for real, in order, against a fresh copy of
[reproducible-analysis-starter](https://github.com/mmulvahill/reproducible-analysis-starter);
this repo's git history is the result, one commit (or two) per step.
The client is fictional; the data and analysis are real.

**Fresh session** means quit and start `claude` again, or open a new
terminal tab: the reviewer must not be the session that wrote the work.
Where Claude asks you questions, the answers given in the rehearsal are
shown; yours can differ.

The numbers after each step (*Things 2, 4*) are the ten things from the
talk that the step shows.

---

## 0. Create the repo

On GitHub, click **Use this template**, name the repo, clone it, `cd`
into it, and run `claude`.

## 1. Set up

> Rename the package to licorice, set the book title to "Licorice Gargle
> Trial: Analysis Notebook and Report" and the repo URL, rewrite the README
> for this project, and commit.

## 2. Intake: paste your notes

Save the client's codebook into `notes/` first (Claude can't read files
outside the project). Then:

> /draft-plan Here are my notes from the intake meeting on 10/10. The
> codebook is in notes/. Don't look at the data yet.
>
> *(paste the notes; the rehearsal's are in
> `notes/2026-10-16-intake-meeting.md`)*

**Expect:** Claude saves the notes unchanged, restates the client's
questions with quotes taken from the notes, lists what it can't tell, and
separates your leanings from decisions. It waits for you. *(Things 2, 3)*

## 3. Work through the plan, one topic at a time

Answer its questions. In the rehearsal:

> Restatement is right. Any = score > 0, at rest; the PI confirmed any
> sore throat is the primary outcome. "Does it last" is a separate odds
> ratio at each time, plus one common odds ratio as a summary; no formal
> interaction test. The PI owns the question and the primary outcome; I
> make the methods calls. No multiplicity adjustment. Swallowing pain stays
> open; cough isn't of interest.

Claude then proposes each topic with its main alternative (population and
unit of analysis, estimands, models, covariates, missing data, reporting)
and logs each decision as you make it. Rehearsal answers, in brief:

> ITT, patient as the unit, keep the preop sore throat patients. Report
> risk differences too. Separate logistic fits per time; exchangeable GEE
> for the common OR. Also fit the random-intercept mixed model and report
> its OR beside the GEE, labeled conditional: reviewers will ask, and
> labels stop the bigger number being quoted. Adjust for sex, age, BMI,
> ASA, smoking and surgery size; not Mallampati; preop sore throat only if
> ten or more patients have it, decided from the baseline count. Complete
> case plus best/worst-case bounds on the primary.

Then:

> Confirmed. Commit the draft.

**Expect:** Chapters 1 and 3 and a dozen decision entries, each with who
decided and its timing ("at planning"). Anything you didn't confirm is
marked *Proposed:*. *(Things 2, 4)*

## 4. Attack the plan, in a fresh session

> /review-plan

**Expect:** a ranked review that edits nothing. In the rehearsal it found,
among others: decisions said to be "PI confirmed" that no note supports;
no defined way to answer "does it last"; a common odds ratio that would be
quoted as a lasting effect; a missing-data assumption never stated; and a
note dated by the wrong day. *(Things 2, 7)*

## 5. Record the client call, revise, and lock the plan

Back in the drafting session (`claude -c`), paste the review and your
answers. Anything the client told you goes in a note, so the record can
cite it:

> Here's the review. I had a call with the PI today; save my notes from it
> as a new note and cite it in the decisions it supports. *(paste call
> notes)* Then: no formal testing across time, but say in the plan that a
> non-significant later time point is not evidence the effect wore off.
> Say plainly the common OR assumes one effect and doesn't answer "does it
> last". State MCAR; revisit if more than 5% are missing at any time.
> Merge covariate categories with fewer than ten patients. Log each change
> as "after review, before any data", then commit and tag the plan plan-v1.

**Expect:** new decisions, an untouched original note plus new ones, and a
`plan-v1` tag. From here, any edit to the plan triggers a reminder to log
it. *(Things 4, 10)*

## 6. Receive the data

Save the delivered file into `data/raw/`, then:

> /receive-data data/raw/licorice_gargle.csv emailed by the PI's fellow
> today; the public medicaldata version, fine to commit, no identifiable
> data.

**Expect:** the checksum recorded in `data/README.md` and the data script;
a structure check against the plan that reads no outcome values (235 rows
against 236 enrolled becomes an open question; the pre-set covariate rules
are applied from baseline counts); a decision that raw data is read-only.
*(Things 1, 9)*

## 7. Clean, with known-answer tests

> Commit the delivery. Then write the cleaning function: one row per
> patient with labeled factors and a patient id, validated against the
> codebook (unexpected codes and out-of-range values stop the pipeline,
> naming the rows), plus the reshape to one row per patient per assessment.
> Known-answer tests on a tiny hand-built raw file first. Then make data,
> and commit.

**Expect:** tests written first and seen failing; in the rehearsal Claude
also broke its own code three ways to check the tests caught each. *(Thing 6)*

## 8. Models, each with simulation-recovery before the real data

> Now the models in the plan, each with its simulation-recovery test
> written and run before anything touches the trial data. Simulate from the
> same structure as the trial, with the marginal truth computed by
> integration. Then break each model on purpose (for example, swap the
> mixed model for a logistic regression that ignores patients) and show me
> which tests fail. If a break passes every test, strengthen the test.
> Commit when done; don't fit anything to the real data yet.

**Expect:** a table of breaks and the tests that caught them. In the
rehearsal an independence-correlation GEE passed every test, so a test was
added; and the Laplace approximation failed the mixed model's recovery
test, so adaptive quadrature was proposed, *before* any result existed.
Confirm it:

> Confirmed: adaptive quadrature, decided by me, before any results. Move
> the break script into scripts/ and commit it.

*(Things 5, 6)*

## 9. Fit everything and write the results

> Fit everything: wire the models into analysis_results(), run make
> results, and check every fit's warnings. Then write the results chapters
> from the computed numbers: data and missingness in Chapter 2 (with the
> bounds), baseline in Chapter 5, the primary analysis in Chapter 6, and a
> new Chapter 7 for durability and the two common odds ratios, labeled
> marginal and conditional. Leave the summary for after the review. make
> all, then commit.

**Expect:** every number inline from `results`; any typed number refused
by the hook. *(Thing 9)*

## 10. Review the analysis, in a fresh session

> /review-analysis

**Expect:** `make all` run and reported, every number traced, the plan
compared with `plan-v1`. In the rehearsal: nothing changed a conclusion,
but a recovery check at the trial's actual clustering lived only in the
research log, claims about the bounds ignored the enrolled patient missing
from the file, and several data-dependent sentences were fixed text.
*(Thing 7)*

## 11. Fix, summarise, publish

In the build session (`claude -c`), paste the review:

> Fix all of it. Commit the recovery scenario as a test. Add the extended
> bound for the missing enrolled patient; it was added after results were
> seen, so log it as post hoc. Make every data-dependent claim computed or
> conditional. Then write the summary answering the client's two
> questions, run make all, and commit.

Read the rendered book (`_book/index.html`), then push to `main`; the book
publishes to GitHub Pages. *(Things 4, 9, 10)*
