---@class snacks.Config
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      dashboard = {
        preset = {
          header = [[
⠀⠀⠀⠀⢀⣤⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣠⠤⠤⠋⢁⠰⢼⡤⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢾⠁⠀⠀⠀⣵⠋⠳⡜⡆⠀⠉⠓⠲⠤⠤⢤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⠳⣒⢄⣀⠻⢻⣟⣵⢻⡿⣿⣦⣄⠀⠀⠀⠀⠉⠳⣄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠙⣖⠭⣑⠠⠰⢬⠜⠀⠈⠻⢷⣶⣤⡀⠀⠀⠈⠻⣟⣶⣄⠀⠀⠀
⠀⠀⠀⠀⠘⢦⡀⠉⠀⠀⠈⠁⠀⠀⠀⠈⠙⠻⢷⣆⡀⠀⠈⢯⡟⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢹⣦⣀⠀⠀⠀⠀⠐⢄⠀⠀⠁⠢⡈⠻⣦⢀⡀⢱⣀⣀⡀
⠀⠀⠀⢀⣠⣼⣝⣿⣿⣷⣄⡘⢄⠀⠀⠢⡀⠀⠀⡰⠊⢀⡤⠞⠉⠀⠈⢳
⠸⠿⠟⣛⡿⣿⠾⡿⣟⠿⢿⣻⢳⠃⠀⠀⢸⠀⣸⠁⠀⡌⠀⠀⠀⢀⠄⡞
⠀⠀⠯⠵⠉⠀⣀⠸⡿⢧⢤⣀⠏⠀⠀⠀⡎⠉⢧⠀⠀⠀⠀⢀⡰⠃⡼⠃
⠀⠀⠀⠀⠀⠘⢭⡭⢍⣉⠂⠉⠀⠀⣠⡾⠃⢀⣈⡢⠤⠄⢒⠁⢠⡞⠁⠀
⠀⠀⠀⠀⠀⠀⠯⠬⠐⠒⠒⠒⠒⠒⠋⠀⠀⣹⣶⡿⢛⠔⣁⡴⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⢼⠍⣓⢵⠞⡡⠞⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠓⠚⠉⠀⠈⠉⠁⠀⠀⠀⠀⠀⠀⠀
       [maxquinn.nz]        ]],
        },
        sections = {
          { section = "header", hl = "DashboardHeader" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      terminal = {
        enabled = true,
        win = {
          position = "float",
          border = "single",
        },
      },
    },
  },
}
