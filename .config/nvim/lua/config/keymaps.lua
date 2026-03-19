-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local wk = require("which-key")

local function copy_relative_file_path()
  local path = vim.fn.expand("%:.") -- relative path from current working directory
  vim.fn.setreg("+", path)
  print("Copied relative file path to clipboard: " .. path)
end

local function goto_outermost()
  local function_types = {
    function_declaration = true,
    arrow_function = true,
    function_expression = true,
    method_definition = true,
  }

  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    print("No treesitter node found.")
    return
  end

  local outermost = nil
  while node do
    if function_types[node:type()] then
      outermost = node
    end
    node = node:parent()
  end

  if outermost then
    local row, col = outermost:start()
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
    vim.cmd("normal! zz")
  else
    print("No function definition found.")
  end
end

-- Normal mode mappings
keymap.set("n", "<M-j>", ":m .+1<CR>==", opts)
keymap.set("n", "<M-k>", ":m .-2<CR>==", opts)
keymap.set("n", "<M-Down>", ":m .+1<CR>==", opts)
keymap.set("n", "<M-Up>", ":m .-2<CR>==", opts)
keymap.set("n", "<C-y>", ":%s/\\<<C-r><C-w>\\>//g<left><left>", opts)

-- Insert mode mappings
keymap.set("i", "<M-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap.set("i", "<M-k>", "<Esc>:m .-2<CR>==gi", opts)
keymap.set("i", "<M-Down>", "<Esc>:m .+1<CR>==gi", opts)
keymap.set("i", "<M-Up>", "<Esc>:m .-2<CR>==gi", opts)

-- Visual mode mappings
keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", opts)
keymap.set("v", "<M-Down>", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "<M-Up>", ":m '<-2<CR>gv=gv", opts)

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Tabs
keymap.set("n", "<Tab>", ":bnext<Return>", opts)
keymap.set("n", "<S-Tab>", ":bprevious<Return>", opts)

-- File manager keymaps are defined in plugins/yazi.lua

wk.add({
  { "<leader>fy", copy_relative_file_path, desc = "Copy relative file path", mode = "n" },
}, opts)

wk.add({
  { "gR", goto_outermost, desc = "Jump to outermost function", mode = "n" },
}, opts)
