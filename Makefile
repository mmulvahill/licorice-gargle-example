.PHONY: all data results test lint numbers book clean

# Set to the received file when data arrives (and in scripts/02_make_analysis_data.R).
RAW_DATA = data/raw/licorice_gargle.csv

all: data results test lint numbers book

# Skips (rather than fails) until the raw file exists, so the book can be
# built and published before data arrives. A changed raw file still fails.
data:
	@if [ -f $(RAW_DATA) ]; then $(MAKE) data/derived/clean.rds; \
	else echo "No raw data yet ($(RAW_DATA) not found); skipping."; fi

data/derived/clean.rds: $(RAW_DATA) scripts/02_make_analysis_data.R R/*.R
	Rscript scripts/02_make_analysis_data.R

# Every model is fitted here, once. The book only reads the saved results.
results: data
	@if [ -f $(RAW_DATA) ]; then $(MAKE) data/derived/results.rds; \
	else echo "No raw data yet; skipping model fits."; fi

data/derived/results.rds: data/derived/clean.rds scripts/03_fit_models.R R/*.R
	Rscript scripts/03_fit_models.R

test:
	Rscript -e 'testthat::test_local(stop_on_failure = TRUE)'

lint:
	Rscript scripts/lint.R

numbers:
	Rscript scripts/check_inline_numbers.R

book: results
	quarto render

clean:
	rm -rf _book data/derived/*.rds
