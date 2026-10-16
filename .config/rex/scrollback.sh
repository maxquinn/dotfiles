#!/usr/bin/env bash
# Dump a pane's full scrollback to a temp file and open it in nvim. Run by the
# scrollback_edit action in init.lua, inside a full-window floating layer.
#
# `rex capture --unwrap` joins soft-wrapped lines, but cells a TUI or a themed
# prompt explicitly painted with spaces survive as trailing whitespace, so we
# strip that ourselves and drop leading and trailing blank lines.

set -euo pipefail

block="${1:?usage: scrollback.sh <block-id> [session-id] [columns]}"
session="${2:-${REX_SESSION:-}}"
width="${3:-}" # the pane's width before it was split, if known

raw="$(mktemp -t rex-scrollback-raw)"
file="$(mktemp -t rex-scrollback)"
trap 'rm -f "$raw" "$file"' EXIT

# On failure, keep the error on screen instead of closing the layer at once
if ! rex capture ${session:+-s "$session"} -b "$block" --trim --unwrap >"$raw"; then
  read -rsn1 -p "Press any key to close."
  exit 1
fi

sed -e 's/[[:space:]]*$//' "$raw" \
  | awk '
      # Non-blank line: flush any buffered interior blanks, then print.
      /[^[:space:]]/ {
        for (i = 0; i < pending; i++) print ""
        pending = 0
        started = 1
        print
        next
      }
      # Blank line: drop it if we have not seen content yet, otherwise buffer
      # it. Buffered blanks are only emitted if more content follows, so
      # trailing blank lines fall off the end.
      started { pending++ }
    ' \
  >"$file"

# Lines the program wrapped itself are rejoined as nvim's first edit, so `u`
# brings back the text as it was in the pane.
reflow=()
if [[ -z "$width" ]]; then
  width="$(rex block call ${session:+-s "$session"} -b "$block" size 2>/dev/null | grep -o '"columns":[0-9]*' | head -1 | cut -d: -f2 || true)"
fi
if [[ -n "$width" ]]; then
  reflow=(-c "silent %!perl '$(dirname "$0")/scrollback-reflow.pl' $width")
fi

# A scratch buffer, so :q never asks to save. `:w path` still writes a copy.
nvim -c 'setlocal buftype=nofile bufhidden=wipe noswapfile' ${reflow[@]+"${reflow[@]}"} -c '$' "$file"
