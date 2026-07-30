#!/usr/bin/env bash
# =============================================================================
# tmux session picker (fzf)
# -----------------------------------------------------------------------------
# Dual purpose:
#   * Outside tmux  -> attaches to the chosen session (used by the `t` shell fn)
#   * Inside tmux   -> switches the current client (used by the M-o popup bind)
# Keys inside the picker:
#   enter   attach / switch to the highlighted session
#   ctrl-x  kill the highlighted session (list reloads)
#   esc     cancel
# The top entry ("＋ new session") prompts for a name and creates one.
# =============================================================================
set -uo pipefail

NEW_ENTRY="＋ new session"

list_sessions() {
  # Newest-active first; empty (no server) is fine.
  tmux list-sessions -F '#{session_name}' 2>/dev/null || true
}

selection=$(
  { printf '%s\n' "$NEW_ENTRY"; list_sessions; } \
    | awk 'NF' \
    | fzf --prompt='tmux ❯ ' \
          --height=100% --layout=reverse --border=rounded \
          --header='enter: switch · ctrl-x: kill · esc: cancel' \
          --bind='ctrl-x:execute-silent(tmux kill-session -t {} 2>/dev/null)+reload(tmux list-sessions -F "#{session_name}" 2>/dev/null)'
) || exit 0

[ -z "$selection" ] && exit 0

if [ "$selection" = "$NEW_ENTRY" ]; then
  read -r -p "New session name: " name
  name=${name:-$(basename "$PWD")}
  # tmux dislikes dots in session names.
  name=${name//./_}
  if [ -n "${TMUX:-}" ]; then
    tmux new-session -d -s "$name" 2>/dev/null || true
    tmux switch-client -t "$name"
  else
    tmux new-session -A -s "$name"
  fi
  exit 0
fi

if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "$selection"
else
  tmux attach-session -t "$selection"
fi
