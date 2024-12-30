local colors = {
  darkgray = "#2f4d69",
  text = "#dcd7ba",
  innerbg = nil,
  outerbg = "#2f4d69",
  normal = "#e79580",
  insert = "#98bb6c",
  visual = "#ffa066",
  replace = "#7e9cd8",
  command = "#e6c384",
}

local theme = {
  inactive = {
    a = { fg = colors.text, bg = colors.outerbg, gui = "bold" },
    b = { fg = colors.text, bg = colors.outerbg },
    c = { fg = colors.text, bg = colors.innerbg },
  },
  visual = {
    a = { fg = colors.darkgray, bg = colors.visual, gui = "bold" },
    b = { fg = colors.text, bg = colors.outerbg },
    c = { fg = colors.text, bg = colors.innerbg },
  },
  replace = {
    a = { fg = colors.darkgray, bg = colors.replace, gui = "bold" },
    b = { fg = colors.text, bg = colors.outerbg },
    c = { fg = colors.text, bg = colors.innerbg },
  },
  normal = {
    a = { fg = colors.darkgray, bg = colors.normal, gui = "bold" },
    b = { fg = colors.text, bg = colors.darkgray },
    c = { fg = colors.text, bg = colors.innerbg },
  },
  insert = {
    a = { fg = colors.darkgray, bg = colors.insert, gui = "bold" },
    b = { fg = colors.text, bg = colors.outerbg },
    c = { fg = colors.text, bg = colors.innerbg },
  },
  command = {
    a = { fg = colors.darkgray, bg = colors.command, gui = "bold" },
    b = { fg = colors.text, bg = colors.outerbg },
    c = { fg = colors.text, bg = colors.innerbg },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = "",
          section_separators = { left = "", right = "" },
          sections = {
            lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
            lualine_b = { "filename", "branch" },
            lualine_c = {
              "%=", --[[ add your center compoentnts here in place of this comment ]]
            },
            lualine_x = {},
            lualine_y = { "filetype", "progress" },
            lualine_z = {
              { "location", separator = { right = "" }, left_padding = 2 },
            },
          },
          inactive_sections = {
            lualine_a = { "filename" },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { "location" },
          },
          tabline = {},
          extensions = {},
          disabled_filetypes = {
            "neo-tree",
            "fzf",
          },
        },
      })
    end,
  },
}
