#!/usr/bin/env bash
# Claude Code Status Line - BubbleTea themed with progress bar and cost tracking

# Read JSON input
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')
session_name=$(echo "$input" | jq -r '.session_name // empty')

# Context window data
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Calculate conversation cost based on model
# Pricing as of early 2025 (adjust as needed)
case "$model_id" in
  *"opus"*)
    input_cost_per_m=15.00
    output_cost_per_m=75.00
    ;;
  *"sonnet"*)
    input_cost_per_m=3.00
    output_cost_per_m=15.00
    ;;
  *"haiku"*)
    input_cost_per_m=0.25
    output_cost_per_m=1.25
    ;;
  *)
    input_cost_per_m=3.00
    output_cost_per_m=15.00
    ;;
esac

# Calculate cost (tokens / 1,000,000 * price per million)
input_cost=$(echo "scale=4; $total_input / 1000000 * $input_cost_per_m" | bc -l 2>/dev/null || echo "0")
output_cost=$(echo "scale=4; $total_output / 1000000 * $output_cost_per_m" | bc -l 2>/dev/null || echo "0")
total_cost=$(echo "scale=2; $input_cost + $output_cost" | bc -l 2>/dev/null || echo "0")

# Git information (with optional locks disabled)
if [ -d "$cwd/.git" ] || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(cd "$cwd" 2>/dev/null && GIT_OPTIONAL_LOCKS=0 git symbolic-ref --quiet --short HEAD 2>/dev/null || GIT_OPTIONAL_LOCKS=0 git rev-parse --short HEAD 2>/dev/null)
  git_status=$(cd "$cwd" 2>/dev/null && GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null)
  if [ -n "$git_status" ]; then
    git_dirty="*"
  else
    git_dirty=""
  fi
fi

# Function to create progress bar with gradient
create_progress_bar() {
  local percentage=$1
  local width=20
  local filled=$(printf "%.0f" $(echo "scale=0; $percentage * $width / 100" | bc))
  local empty=$((width - filled))

  # Gradient colors: Dark Purple #4A2B7F (74,43,127) -> Pink #EE6FF8 (238,111,248)
  local start_r=74 start_g=43 start_b=127
  local end_r=238 end_g=111 end_b=248

  # Draw filled portion with gradient
  for ((i=0; i<filled; i++)); do
    # Calculate color for this position (more gradual with 20 characters)
    local pos=$(echo "scale=4; $i / ($width - 1)" | bc)
    local r=$(printf "%.0f" $(echo "$start_r + ($end_r - $start_r) * $pos" | bc))
    local g=$(printf "%.0f" $(echo "$start_g + ($end_g - $start_g) * $pos" | bc))
    local b=$(printf "%.0f" $(echo "$start_b + ($end_b - $start_b) * $pos" | bc))
    printf '\033[38;2;%d;%d;%dm█' "$r" "$g" "$b"
  done

  # Draw empty portion in darker purple
  printf '\033[38;2;107;79;157m' # Darker purple #6B4F9D
  for ((i=0; i<empty; i++)); do printf '░'; done
  printf '\033[0m'
}

# BubbleTea color palette:
# Purple: #7D56F4 (125,86,244) - primary
# Pink: #EE6FF8 (238,111,248) - accent
# Cyan: #5BCEFA (91,206,250) - info
# Green: #42E66C (66,230,108) - success
# Yellow: #FFFB8C (255,251,140) - warning
# Red: #FF5F87 (255,95,135) - error
# Dark Purple: #6B4F9D (107,79,157) - muted (visible on dark backgrounds)
# Gradient: #4A2B7F (74,43,127) -> #EE6FF8 (238,111,248) - progress bar

# Build status line

# Directory (cyan)
printf '\033[38;2;91;206;250m%s\033[0m' "$(basename "$cwd")"

# Git branch (pink) - Group 1: Location (directory on branch)
if [ -n "$git_branch" ]; then
  printf ' \033[38;2;107;79;157mon\033[0m \033[38;2;238;111;248m%s\033[0m' "$git_branch"
  # Git dirty indicator (red)
  if [ -n "$git_dirty" ]; then
    printf '\033[38;2;255;95;135m%s\033[0m' "$git_dirty"
  fi
fi

# Session name (yellow) - Group 2: Session
if [ -n "$session_name" ]; then
  printf '  \033[38;2;255;251;140m(%s)\033[0m' "$session_name"
fi

# Model (darker purple) - Group 3: Model
printf '  \033[38;2;107;79;157m[%s]\033[0m' "$model"

# Context usage with progress bar - Group 4: Context
if [ "$used_pct" != "0" ] && [ "$used_pct" != "null" ]; then
  printf '  '
  create_progress_bar "$used_pct"
  printf ' \033[38;2;66;230;108m%d%%\033[0m' "$used_pct"
fi

# Cost (purple if > 0) - Group 5: Cost
if [ "$total_cost" != "0" ] && [ "$total_cost" != "0.00" ]; then
  printf '  \033[38;2;125;86;244m$%s\033[0m' "$total_cost"
fi
