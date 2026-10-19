-- Edit Scrollback in nvim: open the source pane's scrollback in nvim, in a new
-- zoomed pane that closes with nvim (tmux: prefix e). Not a floating layer,
-- because Rex draws layers see-through. scrollback.sh does the capturing, and
-- scrollback-reflow.pl rejoins lines that programs wrapped.

local terminal = "com.superlogical.terminal"
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
