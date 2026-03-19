return {
  {
    "saghen/blink.cmp",
    init = function()
      vim.api.nvim_create_autocmd("InsertEnter", {
        once = true,
        callback = function()
          vim.schedule(function()
            local ok, list = pcall(require, "blink.cmp.completion.list")
            if not ok then return end

            local original_show = list.show
            list.show = function(context, items_by_source)
              local prev_idx = list.selected_item_idx
              local was_explicitly_selected = list.is_explicitly_selected

              local is_same_context = list.context and list.context.id == context.id
              local bounds_unchanged = list.context ~= nil
                and list.context.bounds.start_col == context.bounds.start_col
                and list.context.bounds.length == context.bounds.length

              original_show(context, items_by_source)

              -- If user had a selection, same context/bounds, but selection was lost
              -- after refresh (item moved past pos 10 or not found), restore at
              -- the same index position clamped to new list size
              if
                was_explicitly_selected
                and is_same_context
                and bounds_unchanged
                and list.selected_item_idx == nil
                and prev_idx ~= nil
                and #list.items > 0
              then
                list.select(math.min(prev_idx, #list.items), { auto_insert = false, undo_preview = false })
              end
            end
          end)
        end,
      })
    end,
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
