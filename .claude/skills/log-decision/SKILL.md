---
name: log-decision
description: Record an analysis decision in DECISIONS.md. Use whenever a choice about outcomes, models, exclusions, covariates, missing data or estimands is made or changed.
argument-hint: "[the decision, in a sentence]"
---

Add a decision to DECISIONS.md for: $ARGUMENTS

1. Read DECISIONS.md and find the highest D-number. The new entry is the
   next number.
2. Append an entry in the same format as the existing ones:
   `## D-NNN: <short title>`, then bullets for **Date** (today) and
   **Decided by**, **Decision**, **Why**, **Timing**, and **Alternatives**.
3. If I did not say who decided or why, ask me before writing. Do not invent
   a rationale.
4. **Timing:** ask whether any results bearing on this decision had been
   seen when it was made, and record the answer. If the decision changes the
   primary outcome, primary model or an estimand after results were seen,
   say plainly that this makes it post hoc and ask me to confirm before
   writing.
5. If this reverses an earlier decision, say "Supersedes D-XXX" in the new
   entry and leave the old entry unchanged.
6. If the decision changes the analysis plan in `chapters/03-methods.qmd`,
   tell me which lines would change and ask before editing them.
