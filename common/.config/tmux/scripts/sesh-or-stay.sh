#!/bin/sh

temp_session=$1

"$TMUX_CONFIG_DIR/scripts/tmux-popup" -d "$HOME" -s large -t "Sesh" -E tv sesh

current_session=$(tmux display-message -p '#S')

if [ "$current_session" != "$temp_session" ]; then
  tmux kill-session -t "$temp_session" 2>/dev/null || true
fi
