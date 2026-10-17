---
name: receive-data
description: Bring a data delivery into data/raw, record its checksum and provenance, and check its structure against the plan. Use whenever a new data file arrives.
argument-hint: "[path to the delivered file] [where it came from]"
---

Receive this data delivery: $ARGUMENTS

1. **Check it is allowed.** Ask me to confirm the data may be used on this
   machine and account and, if this repo is pushed anywhere, whether it may
   be committed. If it contains identifiable data, stop: it belongs in
   `data/phi/` (never committed, never read by Claude) or not here at all.
2. **Get it into `data/raw/` unchanged.** If I have already saved it there,
   use it as is. Otherwise copy it in with `cp`, keeping its name (add a
   date if a file of that name exists). If the file is outside the folders
   you can reach, ask me to save it into `data/raw/` myself; never re-create
   it by reading and writing it, which can change its bytes. Never open a
   raw file for editing or overwrite one.
3. **Record it.** Compute its MD5. Add a row to the table in
   `data/README.md` (file, date received, source, MD5) and the codebook
   location. A codebook that came with the data goes in `notes/` unchanged. Set `raw_path` and `expected_md5` in
   `scripts/02_make_analysis_data.R` and `RAW_DATA` in the `Makefile`.
4. **Check structure, not outcomes.** Report the number of rows and columns,
   the column names, and whether every variable the plan
   (`chapters/03-methods.qmd`) uses is present. Compare the row count with
   what the notes or protocol say was enrolled. Do not summarise outcome
   values; the plan comes first (CLAUDE.md rule 4).
5. **Log it.** Add a dated `RESEARCH_LOG.md` entry with what arrived and
   anything that disagrees with the plan or the notes. Anything that
   disagrees becomes an open question in `chapters/01-question.qmd`. Use
   `/log-decision` for the decision to treat the file as read-only and
   checksum-guarded, if it is the project's first delivery.
6. Run `make data`. Until `clean_data()` in `R/clean.R` is written it stops
   with "not written yet"; say so and stop there.
