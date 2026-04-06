#!/bin/bash

SESSION="dev"
DIR="${1:-$(pwd)}"

# Handle existing session
if tmux has-session -t $SESSION 2>/dev/null; then
  read -r -p "Session '$SESSION' already exists. Kill and recreate it? (y/n): " choice
  case "$choice" in
  y | Y) tmux kill-session -t $SESSION ;;
  *)
    tmux attach -t $SESSION
    exit 0
    ;;
  esac
fi

# Window 1: Neovim
tmux new-session -d -s $SESSION -n nvim -x "$(tput cols)" -y "$(tput lines)"
tmux select-pane -t $SESSION:1 -T "Neovim"
tmux set-option -t $SESSION:1 remain-on-exit on
tmux respawn-pane -t $SESSION:1 -k "cd $DIR && nvim ."

# Window 2: Claude + npm run dev
tmux new-window -t $SESSION -n claude
tmux set-option -t $SESSION:2 remain-on-exit on
tmux respawn-pane -t $SESSION:2 -k "cd $DIR && claude"
tmux split-window -t $SESSION:2 -h -p 30
tmux set-option -t $SESSION:2.2 remain-on-exit on
tmux respawn-pane -t $SESSION:2.2 -k "cd $DIR && npm run dev"
tmux select-pane -t $SESSION:2.2 -T "Dev Server"
tmux select-pane -t $SESSION:2.1

# Window 3: Lazygit
tmux new-window -t $SESSION -n lazygit
tmux set-option -t $SESSION:3 remain-on-exit on
tmux respawn-pane -t $SESSION:3 -k "cd $DIR && lazygit"
tmux select-pane -t $SESSION:3 -T "Lazygit"

# Start on window 1
tmux select-window -t $SESSION:1

tmux attach -t $SESSION
