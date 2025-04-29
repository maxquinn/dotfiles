-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- diable copilot cmp
vim.g.ai_cmp = false
vim.g.copilot_no_tab_map = true

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = true
--disable lsp logs
vim.lsp.set_log_level("ERROR")

vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

-- set titlestring to $cwd if TERM_PROGRAM=ghostty
if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
  vim.opt.title = true
  vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"
end
