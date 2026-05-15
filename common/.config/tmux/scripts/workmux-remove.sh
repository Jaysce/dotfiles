#!/bin/sh
# Prompt for a worktree name and remove it with Workmux.

set -eu

force=""
if [ "${1:-}" = "--force" ]; then
  force="--force"
fi

worktrees=$(workmux list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -Ev '^(main|master)$' || true)

if [ -z "$worktrees" ]; then
  printf 'No Workmux worktrees to remove.\n\nPress Enter to close...'
  IFS= read -r _ || true
  exit 0
fi

current=$(git branch --show-current 2>/dev/null || true)

if command -v gum >/dev/null 2>&1; then
  if [ -n "$force" ]; then
    header="Branch to force remove"
  else
    header="Branch to remove"
  fi
  branch=$(printf '%s\n' "$worktrees" | gum filter --header "$header" --value "$current" --placeholder "current worktree" --no-strict) || exit 0
else
  printf 'Worktrees:\n%s\n\nBranch to remove [%s]: ' "$worktrees" "$current"
  IFS= read -r branch || exit 0
  [ -n "$branch" ] || branch=$current
fi

[ -n "$branch" ] || exit 0

if [ -z "$force" ]; then
  if command -v gum >/dev/null 2>&1; then
    gum confirm "Remove worktree '$branch'?" || exit 0
  else
    printf "Remove worktree '%s'? [y/N] " "$branch"
    IFS= read -r answer || exit 0
    case "$answer" in
      y|Y|yes|YES) ;;
      *) exit 0 ;;
    esac
  fi
fi

if ! workmux remove $force "$branch"; then
  printf '\nWorkmux remove failed. Press Enter to close...'
  IFS= read -r _ || true
fi
