intake mtg 10/10 — anesth PI + their fellow, ~40 min

- RCT, licorice gargle vs sugar water gargle, 5 min before induction
- thoracic surgery, double-lumen tubes (big tubes -> lots of sore throat, that's the whole point)
- PI: "did it reduce sore throat afterwards?" want something for a manuscript
- also: "does it last past the recovery room?" — they care about this a lot, said reviewers will ask
- sore throat assessed: PACU 30 min, PACU 90 min, 4h post-op, POD1 morning
  - 0-10 scale (at rest). also swallowing pain at 30 min only? and cough. ask
- they think primary = any sore throat at 30 min. "any" = score > 0?? confirm. threshold instead?
- 236 enrolled I think. data already cleaned per them (believe it when I see it)
- a couple pts no post-op data? they weren't sure
- baseline: sex, age, BMI, ASA, mallampati, smoking (current/past/never), preop sore throat, surgery size (S/M/L)

my thoughts
- randomized -> unadjusted primary, adjusted as sensitivity. pick covariates BEFORE looking
- 4 timepoints per pt = repeated measures. GEE vs mixed model? their q sounds population-level
  -> marginal OR. GLMM OR will be bigger (non-collapsible), don't let anyone quote that one
- "does it last" -> OR at each timepoint? interaction w/ time
- missing: if it's only a couple, complete case + best/worst case bounds
- dichotomizing 0-10 loses info, ordinal model as secondary maybe. not now

data: they'll send a csv + codebook. it's the public version (medicaldata pkg) fine to use
todo: ask about swallowing pain as a 2nd outcome. ask why 236 vs whatever's in the file
