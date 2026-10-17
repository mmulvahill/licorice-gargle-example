# Refuse typed numbers in report prose.
#
# Every result in the book must come from inline R (`r fmt_pct(x)`), so it
# changes when the data or code change. This check strips YAML, code chunks
# and inline code, then flags any remaining digits in prose.
#
# Allowed without inline code: "Table 1", "Figure 2", "Chapter 3",
# "Section 4", "D-001" decision ids, 4-digit years, and anything inside a
# markdown link or URL. A person can allow one line deliberately by ending
# it with <!-- numbers-ok -->; the error message does not offer this, so an
# assistant is steered to compute the number instead.
#
# Usage: Rscript scripts/check_inline_numbers.R [files...]
# Default: every .qmd file in the repo root and chapters/.

args <- commandArgs(trailingOnly = TRUE)
files <- if (length(args) > 0) {
  args
} else {
  c(list.files(".", pattern = "\\.qmd$"),
    list.files("chapters", pattern = "\\.qmd$", full.names = TRUE))
}

strip_line <- function(line) {
  line <- gsub("`r [^`]*`", "", line)            # inline R
  line <- gsub("`[^`]*`", "", line)              # other inline code
  line <- gsub("\\[[^]]*\\]\\([^)]*\\)", "", line) # markdown links
  line <- gsub("https?://\\S+", "", line)        # bare URLs
  line <- gsub("<[^>]+>", "", line)              # html tags / comments
  line <- gsub("@[A-Za-z0-9_:-]+", "", line)     # cross-refs and citations
  line <- gsub("\\b(Table|Figure|Chapter|Section|Appendix)\\s+\\d+", "", line)
  line <- gsub("\\bD-\\d+\\b", "", line)         # decision ids
  line <- gsub("95% CI", "", line, fixed = TRUE)  # the conventional label
  line <- gsub("\\b[A-Za-z]+[0-9][A-Za-z0-9]*\\b", "", line) # names like MD5
  line <- gsub("\\b(19|20)\\d{2}\\b", "", line)  # years
  line <- gsub("^\\s*#+\\s*", "", line)          # heading markers
  line <- gsub("^\\s*\\d+\\.\\s", "", line)      # numbered-list markers
  line
}

# TRUE for lines that are prose: not YAML front matter, not inside a code
# chunk, not a chunk fence, and not marked numbers-ok.
is_prose <- function(lines) {
  fence <- grepl("^\\s*(```|~~~)", lines)
  in_chunk <- (cumsum(fence) %% 2 == 1) | fence
  yaml_end <- 0
  if (length(lines) > 0 && trimws(lines[1]) == "---") {
    closers <- which(trimws(lines) == "---")
    yaml_end <- if (length(closers) > 1) closers[2] else length(lines)
  }
  in_yaml <- seq_along(lines) <= yaml_end
  !in_chunk & !in_yaml & !grepl("numbers-ok", lines, fixed = TRUE)
}

problems <- character()
for (f in files) {
  lines <- readLines(f, warn = FALSE)
  prose <- vapply(lines, strip_line, character(1), USE.NAMES = FALSE)
  flagged <- which(is_prose(lines) & grepl("[0-9]", prose))
  problems <- c(problems, sprintf("%s:%d: %s", f, flagged, trimws(lines[flagged])))
}

if (length(problems) > 0) {
  cat("Typed numbers found in report prose. Compute each one from data or",
      "results with inline R, e.g. `r fmt_pct(x)`:\n\n")
  cat(problems, sep = "\n")
  quit(status = 1)
}
cat("No typed numbers in prose (", length(files), " files checked).\n", sep = "")
