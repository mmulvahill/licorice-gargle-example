# Data deliveries

Files in `data/raw/` are exactly as received. Never edit them; every change happens in
code (`scripts/02_make_analysis_data.R`), which refuses to run if a raw
file's checksum changes.

| File | Received | Source | MD5 |
|---|---|---|---|
| `licorice_gargle.csv` | 2026-10-16 | Emailed by the PI's fellow; public version from the `medicaldata` R package | `fe23d586f6bdc92a5db1342f8e41a283` |

Codebook: `notes/2026-10-16-codebook.md`

This table lives here, not in `data/raw/`, because Claude's file tools may
not edit anything in `data/raw/`. A new delivery is saved as a new file (e.g. `study_data_2026-11-02.csv`),
added to this table, and logged in DECISIONS.md.
