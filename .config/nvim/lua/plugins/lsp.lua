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
        tsc = {},
        -- terraform-ls has root_markers = { ".terraform", ".git" }, so in this repo it
        -- rooted at the git root and recursively indexed all of node_modules.
        -- Prefer real terraform markers (iac/components/*/.terraform.lock.hcl), fall
        -- back to .git, and hard-exclude JS dirs from indexing either way.
        terraformls = {
          root_markers = { { ".terraform", ".terraform.lock.hcl" }, ".git" },
          init_options = {
            indexing = {
              ignoreDirectoryNames = {
                "node_modules",
                ".next",
                ".turbo",
                "dist",
                "build",
                "coverage",
                "generated-client",
              },
            },
          },
        },
        -- oxlint shells out to tsgolint via spawnSync for type-aware linting; on a repo
        -- this size, lint-on-type spawned enough concurrent processes to hit the proc
        -- limit and die with EAGAIN. Match eslint and only lint on save.
        oxlint = {
          settings = {
            run = "onSave",
          },
        },
        -- vtsls = {
        --   -- explicitly disable formatting for vtsls so eslint/prettier takes over
        --   -- this is cleaner than doing it in the 'setup' hook
        --   on_attach = function(client)
        --     client.server_capabilities.documentFormattingProvider = false
        --   end,
        --   settings = {
        --     complete_function_calls = true,
        --     vtsls = {
        --       enableMoveToFileCodeAction = true, -- Essential for refactoring
        --       autoUseWorkspaceTsdk = true, -- Uses your project's TS version (faster/more accurate)
        --       experimental = {
        --         maxInlayHintLength = 30,
        --         completion = {
        --           enableServerSideFuzzyMatch = true, -- optimization for large completion lists
        --           entriesLimit = 50, -- Cap completion entries for better performance
        --         },
        --       },
        --     },
        --     typescript = {
        --       preferGoToSourceDefinition = false,
        --       tsserver = {
        --         maxTsServerMemory = 8192, -- Increase memory limit for large codebases (default: 3072)
        --         enableTracing = false,
        --         log = "off",
        --       },
        --       updateImportsOnFileMove = { enabled = "always" },
        --       preferences = {
        --         importModuleSpecifier = "non-relative",
        --         includePackageJsonAutoImports = "off", -- Disable expensive package.json auto-imports
        --         autoImportFileExcludePatterns = {
        --           "**/node_modules/@types/**",
        --           "**/node_modules/@aws-sdk/**",
        --           "**/node_modules/@udecode/**",
        --           "**/generated-client/**",
        --         },
        --       },
        --     },
        --   },
        -- },
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
