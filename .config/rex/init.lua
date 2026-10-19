-- Rex config, mirroring ~/.tmux.conf
-- Apply changes with: rex config reload
--
-- Features live in their own files and define actions; this file loads them
-- and holds every key binding.

-- =============================================================================
-- PREFIX (ctrl+b, as in tmux)
-- =============================================================================

-- Reload config (tmux: prefix r)
rex.bind("ctrl+b>r", "client.config.reload")

-- tmux defaults you probably have in muscle memory
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>,", "client.tab.rename")
rex.bind("ctrl+b>shift+4", "session.rename") -- prefix $
for i = 1, 9 do
  rex.bind("ctrl+b>" .. i, "client.tab.goto", { index = i })
end

-- Edit the focused pane's scrollback in nvim (tmux: prefix e; see scrollback.lua)
require("scrollback")
rex.bind("ctrl+b>e", "scrollback_edit")

-- Save and restore sessions across restarts (see sessions.lua)
require("sessions")
rex.bind("ctrl+b>shift+s", "sessions_save")
rex.bind("ctrl+b>shift+r", "sessions_restore")

-- Review the pane's branch against main in hunk (see open-diff.lua)
require("open-diff")

-- Press ctrl+b twice to send ctrl+b to the terminal
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- =============================================================================
-- NO PREFIX (alt, as in tmux bind -n M-*)
-- =============================================================================

-- Pane navigation, like vim-tmux-navigator (see navigation.lua)
local navigate = require("navigation")
rex.bind("ctrl+h", navigate("left"))
rex.bind("ctrl+j", navigate("down"))
rex.bind("ctrl+k", navigate("up"))
rex.bind("ctrl+l", navigate("right"))

-- Session switcher (tmux: M-o fzf popup)
rex.bind("alt+o", "session.switch")

-- Tabs (tmux windows)
rex.bind("alt+t", "client.tab.new")
rex.bind("alt+h", "client.tab.previous")
rex.bind("alt+l", "client.tab.next")

-- Panes
rex.bind("alt+v", "pane.split", { direction = "right" })
rex.bind("alt+s", "pane.split", { direction = "down" })
rex.bind("alt+x", "pane.close")
rex.bind("alt+k", "pane.move", { direction = "up" })
rex.bind("alt+j", "pane.move", { direction = "down" })

-- Resizing (amount is a percentage of the split; Rex's default is 5)
rex.bind("alt+shift+h", "pane.resize", { direction = "left", amount = 2 })
rex.bind("alt+shift+j", "pane.resize", { direction = "down", amount = 2 })
rex.bind("alt+shift+k", "pane.resize", { direction = "up", amount = 2 })
rex.bind("alt+shift+l", "pane.resize", { direction = "right", amount = 2 })
