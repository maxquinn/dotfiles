-- Pane navigation, like vim-tmux-navigator. When the focused pane runs vim
-- or fzf, the key goes to it; nvim moves between its own splits and calls
-- `rex focus` at its edge (see ~/.config/nvim/lua/plugins/tmux-navigator.lua).
--
-- Returns navigate(direction), which makes a key binding function. It has to
-- be a function rather than an action, since only a function can hand the key
-- on to the terminal by returning false.

local terminal = "com.superlogical.terminal"

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

return function(direction)
  return function(ctx)
    if runs_vim(ctx) then
      return false -- send the key to vim
    end
    rex.session.focus_direction{ direction = direction, wrap = true }
    return true
  end
end
