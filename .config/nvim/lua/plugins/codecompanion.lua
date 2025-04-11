return {
  {
    "olimorris/codecompanion.nvim",
    config = function()
      require("codecompanion").setup({
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:op read op://private/Anthropic/credential --no-newline",
              },
            })
          end,
        },
        strategies = {
          chat = {
            adapter = "anthropic",
            keymaps = {
              close = {
                modes = { n = "<C-w>", i = "<C-w>" },
              },
            },
            slash_commands = {
              ["file"] = {
                opts = {
                  provider = "snacks",
                },
              },
              ["buffer"] = {
                opts = {
                  provider = "snacks",
                },
              },
            },
          },
          inline = {
            adapter = "anthropic",
          },
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
