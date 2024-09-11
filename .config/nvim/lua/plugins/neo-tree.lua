return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "float",
    },
    filesystem = {
      filtered_items = {
        -- visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          ".git",
        },
      },
    },
  },
}
