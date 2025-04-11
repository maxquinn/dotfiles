return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { auto_show = true, border = "rounded" },
        documentation = {
          window = { border = "rounded" },
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        ghost_text = {
          enabled = false,
        },
      },
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-/>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },

        ["<C-p>"] = { "snippet_backward", "fallback" },
        ["<C-n>"] = { "snippet_forward", "fallback" },

        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
    },
  },
}
