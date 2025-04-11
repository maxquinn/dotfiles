return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
        },
        -- vtsls = {
        --   settings = {
        --     typescript = {
        --       preferences = {
        --         importModuleSpecifier = "non-relative",
        --       },
        --     },
        --   },
        -- },
        ts_ls = {
          init_options = {
            preferences = {
              importModuleSpecifierPreference = "non-relative",
              importModuleSpecifierEnding = "minimal",
            },
          },
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
      setup = {
        eslint = function()
          -- automatically fix linting errors on save (but otherwise do not format the document)
          vim.cmd([[
          autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll
        ]])
        end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "typescript-language-server" })
    end,
  },
}
