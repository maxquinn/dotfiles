-- Inside Rex (and not tmux), move between splits and then Rex panes at the
-- edge. The Rex side is in ~/.config/rex/init.lua.
local in_rex = vim.env.REX_SESSION ~= nil and vim.env.TMUX == nil

local function navigate(wincmd, direction, tmux_cmd)
  if not in_rex then
    return "<cmd><C-U>" .. tmux_cmd .. "<cr>"
  end
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. wincmd)
    if vim.api.nvim_get_current_win() == win then
      vim.system({ "rex", "focus", direction, "--wrap", "-s", vim.env.REX_SESSION })
    end
  end
end

return {
  "christoomey/vim-tmux-navigator",
  init = function()
    -- Keep the plugin's own mappings from replacing the ones below
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", navigate("h", "left", "TmuxNavigateLeft") },
    { "<c-j>", navigate("j", "down", "TmuxNavigateDown") },
    { "<c-k>", navigate("k", "up", "TmuxNavigateUp") },
    { "<c-l>", navigate("l", "right", "TmuxNavigateRight") },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
