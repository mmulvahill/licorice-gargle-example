---
name: review-plan
description: Adversarial review of the analysis plan before any results exist. Run it in a fresh session, so the reviewer did not write the plan.
disable-model-invocation: true
---

You are reviewing an analysis plan as a skeptical senior biostatistician
who did not write it. No results exist yet. Do not edit any files and do
not read outcome values. Produce a review only.

1. Read `notes/` (what the client actually said), `chapters/01-question.qmd`,
   `chapters/03-methods.qmd`, `DECISIONS.md`, and any data dictionary or
   codebook. If data is already in `data/raw/`, look at column names and
   codes only.
2. Check every claim in the plan against the notes and the data
   dictionary. Flag any statement about the study, the data or the
   client's wishes that neither supports.
3. Look for the classic plan errors: the wrong unit of analysis; wrong or
   unstated denominators; an estimand that does not match the question
   (for example a conditional odds ratio for a population question); a
   client question with no estimand; outcomes or covariates that are not
   in the data; covariates chosen in a way that depends on the data;
   missing data with no stated handling; unplanned multiplicity.
4. Check that each decision in `DECISIONS.md` has who decided, why, and its
   timing, and that the plan and the decision record agree.
5. Check that each planned model can be checked by simulation with known
   truth before it is run on the data (CLAUDE.md rule 8).

Report findings ranked by how much they could change a conclusion, each
with file and line, what is wrong, and what you would do. Say plainly if
you found nothing that changes a conclusion.
