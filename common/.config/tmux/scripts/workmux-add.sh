#!/bin/sh
# Prompt for a branch name and create a Workmux worktree.

set -eu

if command -v gum >/dev/null 2>&1; then
  branch=$(gum input --header "Branch name" --prompt "> ") || exit 0
else
  printf 'Branch name: '
  IFS= read -r branch || exit 0
fi

[ -n "$branch" ] || exit 0

if ! workmux add "$branch"; then
  printf '\nWorkmux add failed. Press Enter to close...'
  IFS= read -r _ || true
fi
