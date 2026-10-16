-- Rex config, mirroring ~/.tmux.conf
-- Apply changes with: rex config reload

local terminal = "com.superlogical.terminal"

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

-- Edit the focused pane's scrollback in nvim, in a new zoomed pane that
-- closes with nvim (tmux: prefix e). Not a floating layer, because Rex draws
-- layers see-through.
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"

rex.action{
  name = "scrollback_edit",
  title = "Edit Scrollback in nvim",
  category = "Pane",
  keywords = "scrollback history buffer copy editor nvim",
  run = function(ctx)
    -- Measure before splitting, which narrows the pane. The script uses the
    -- width to rejoin lines that programs wrapped.
    local size = rex.block.call(terminal, "size", { block_id = ctx.block_id })
    local columns = size and tostring(size.columns) or ""
    local split, err = rex.session.new_split{
      anchor_block_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { command = { config_dir .. "/scrollback.sh", ctx.block_id, ctx.session_id, columns } },
      },
    }
    if not split then
      error(err)
    end
    rex.session.zoom_block{ block_id = split.block_ids[1], zoom = true }
    return split
  end,
}
rex.bind("ctrl+b>e", "scrollback_edit")

-- Press ctrl+b twice to send ctrl+b to the terminal
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- =============================================================================
-- NO PREFIX (alt, as in tmux bind -n M-*)
-- =============================================================================

-- Pane navigation, like vim-tmux-navigator. When the focused pane runs vim
-- or fzf, the key goes to it; nvim moves between its own splits and calls
-- `rex focus` at its edge (see ~/.config/nvim/lua/plugins/tmux-navigator.lua).
local function runs_vim(ctx)
  local proc = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  local fg = proc and proc.foreground
  if not fg then
    return false
  end
  for _, name in ipairs({ fg.name, fg.argv0 }) do
    name = (name or ""):match("[^/]+$") or ""
    for _, pattern in ipairs({ "^g?view$", "^g?l?n?vim?x?$", "^g?l?n?vimdiff$", "^fzf$" }) do
      if name:match(pattern) then
        return true
      end
    end
  end
  return false
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    if runs_vim(ctx) then
      return false -- send the key to vim
    end
    rex.session.focus_direction{ direction = direction, wrap = true }
    return true
  end)
end

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
