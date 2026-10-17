# Lint every R and Quarto file the project ships; exit non-zero on any lint.
# An explicit file list (rather than lint_dir() exclusions) behaves the same
# across lintr versions.

files <- c(
  list.files(".", pattern = "\\.(R|qmd)$"),
  list.files(c("R", "tests", "scripts", "chapters"),
             pattern = "\\.(R|qmd)$", recursive = TRUE, full.names = TRUE)
)

lints <- unlist(lapply(files, lintr::lint), recursive = FALSE)
class(lints) <- "lints"
print(lints)
cat(length(files), "files linted,", length(lints), "lints\n")
quit(status = as.integer(length(lints) > 0))
