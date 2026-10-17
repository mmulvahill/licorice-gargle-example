#!/usr/bin/env bash
# Claude Code hook: after an edit to the question or the plan, remind Claude
# that a locked plan (a plan-* git tag) changes only with a decision entry.
# Reads the hook's JSON on stdin; exit 2 shows the message to Claude.

input=$(cat)
if ! grep -qE 'chapters/0(1-question|3-methods)\.qmd' <<<"$input"; then
  exit 0
fi
tag=$(git tag -l 'plan-*' --sort=-creatordate | head -n 1)
if [ -z "$tag" ]; then
  exit 0
fi
echo "The plan was locked at tag $tag. Log this change with /log-decision" \
  "(post hoc if any results have been seen), and mark it in the chapter." >&2
exit 2
