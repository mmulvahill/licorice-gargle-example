---
name: draft-plan
description: Turn intake notes into the question and the analysis plan by talking it through with the analyst. Use at the start of a project, or when new notes from the client change the question or the plan.
argument-hint: "[path to notes in notes/, or paste the notes]"
---

Draft `chapters/01-question.qmd` and `chapters/03-methods.qmd` with me from
these notes: $ARGUMENTS

If the notes were pasted rather than given as a file, first save them
unchanged as `notes/YYYY-MM-DD-<topic>.md` (today's date). Files in
`notes/` are never edited afterwards.

1. **Read first.** Read the notes, `CLAUDE.md`, both chapters, and
   `DECISIONS.md`. If a data dictionary or codebook is available, read it.
   Do not read outcome values: the plan comes before results (CLAUDE.md
   rule 4). Column names, codes and baseline structure are fine.
2. **Restate before drafting.** In a few lines, tell me what you think the
   client is asking, the primary and secondary questions, and what you
   could not tell from the notes. Wait for me to correct you.
3. **Work through one topic at a time, asking as you go:** the question and
   its restatement; the population and the unit of analysis; the outcomes
   and how they are defined; the estimands (and which question each one
   answers); the models; adjustment covariates; missing data; how results
   will be reported. Propose an option with its main alternative and why,
   then ask. Do not move on while I have not decided.
4. **Never put words in anyone's mouth.** Quote the client only from the
   notes, verbatim. Anything I have not confirmed goes in the chapter as
   *Proposed:* or as an open question, never as a decision.
5. **Log decisions as they are made.** When I confirm a choice about an
   outcome, model, estimand, covariates, exclusions or missing data, write
   it with `/log-decision` (Timing: at planning, before any outcome was
   examined). Ask me who decided if I have not said.
6. **Every client question gets an answer in the plan.** Before finishing,
   list each question from the notes and the estimand that answers it. Any
   question without one is an open question in Chapter 1.
7. **Finish** by running `make numbers` and `make lint`, then tell me what
   is still open. Suggest I commit the draft and run `/review-plan` in a
   fresh session before the plan is locked.
