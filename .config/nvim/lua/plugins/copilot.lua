return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-CR>",
          accept_word = "<C-j>",
          next = "<M-S-]>",
          prev = "<M-S-[>",
        },
      },
      panel = { enabled = false },
    },
  },
}
