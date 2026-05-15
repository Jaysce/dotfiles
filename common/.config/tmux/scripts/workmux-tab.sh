#!/bin/sh
# Toggle a dedicated Workmux dashboard window.

set -eu

window_name="workmux"
current_window=$(tmux display-message -p '#{window_name}')

if [ "$current_window" = "$window_name" ]; then
  tmux last-window
elif tmux list-windows -F '#{window_name}' | grep -qx "$window_name"; then
  tmux select-window -t "$window_name"
else
  pane_path=$(tmux display-message -p '#{pane_current_path}')
  tmux new-window -n "$window_name" -c "$pane_path" "workmux dashboard --tab worktrees"
fi
