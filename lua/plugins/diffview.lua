-- ~/.config/nvim/lua/plugins/diffview.lua
return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
      { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: Compare with HEAD~1" },
      { "<leader>ge", "<cmd>DiffviewOpen develop<cr>", desc = "Diffview: Compare with develop" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File history (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Git history (project)" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
    },
    config = function()
      local diffview = require("diffview")
      local actions = require("diffview.actions")

      diffview.setup({
        use_icons = true,
        enhanced_diff_hl = true,
        view = {
          default = { layout = "diff2_horizontal" },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
          },
        },
        keymaps = {
          view = {
            { "n", "gd", actions.select_next_entry, { desc = "Next diff entry" } },
            { "n", "gD", actions.select_prev_entry, { desc = "Previous diff entry" } },
          },
          file_panel = {
            { "n", "gd", actions.select_next_entry, { desc = "Next diff entry" } },
            { "n", "gD", actions.select_prev_entry, { desc = "Previous diff entry" } },
          },
        },
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
        },
        hooks = {
          diff_buf_read = function(bufnr)
            vim.opt_local.wrap = false
            vim.opt_local.list = false
          end,
        },
      })
    end,
  },
}
