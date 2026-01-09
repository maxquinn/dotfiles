return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            run = "onSave",
          },
        },
        vtsls = {
          -- explicitly disable formatting for vtsls so eslint/prettier takes over
          -- this is cleaner than doing it in the 'setup' hook
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true, -- Essential for refactoring
              autoUseWorkspaceTsdk = true, -- Uses your project's TS version (faster/more accurate)
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true, -- optimization for large completion lists
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              preferences = {
                importModuleSpecifier = "non-relative",
              },
            },
          },
        },
      },
      setup = {
        eslint = function()
          require("snacks.util").lsp.on(function(_, client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "vtsls" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
}
