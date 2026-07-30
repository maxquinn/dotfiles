#!/usr/bin/env bash
# Dump a pane's full scrollback to a temp file and open it in nvim in a popup.
#
# Why the post-processing: `capture-pane -J` joins wrapped lines (good) but it
# also PRESERVES trailing spaces (see tmux(1): "-J preserves trailing spaces and
# joins any wrapped lines"). -J implies -T, which only drops cells that were
# never written to -- so every space a TUI or a themed prompt explicitly painted
# survives into the capture. We keep -J for the line joining and strip the
# trailing whitespace ourselves.

set -euo pipefail

pane="${1:?usage: scrollback.sh <pane-id>}"
file="/tmp/tmux-scrollback-${pane}"

tmux capture-pane -p -J -S - -t "$pane" \
  | sed -e 's/[[:space:]]*$//' \
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
  > "$file"

tmux display-popup -E -w 100% -h 100% -t "$pane" "nvim + '$file'"
