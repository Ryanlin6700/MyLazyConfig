return {
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("scrollbar").setup({
        show = true,
        show_in_active_only = true,
        hide_if_all_visible = false,
        throttle_ms = 100,
        handle = {
          text = " ",
          blend = 30,
          highlight = "CursorColumn",
          hide_if_all_visible = true,
        },
        marks = {
          Cursor = { text = " ", priority = 0, highlight = "Normal" },
          Search = { text = { "-", "=" }, priority = 1, highlight = "Search" },
          Error = { text = { "-", "=" }, priority = 2, highlight = "DiagnosticVirtualTextError" },
          Warn = { text = { "-", "=" }, priority = 3, highlight = "DiagnosticVirtualTextWarn" },
          Info = { text = { "-", "=" }, priority = 4, highlight = "DiagnosticVirtualTextInfo" },
          Hint = { text = { "-", "=" }, priority = 5, highlight = "DiagnosticVirtualTextHint" },
          Misc = { text = { "-", "=" }, priority = 6, highlight = "Normal" },
          GitAdd = { text = "█", priority = 7, highlight = "GitSignsAdd" },
          GitChange = { text = "█", priority = 7, highlight = "GitSignsChange" },
          GitDelete = { text = "█", priority = 7, highlight = "GitSignsDelete" },
        },
        excluded_buftypes = {
          "terminal",
        },
        excluded_filetypes = {
          "blink-cmp-menu",
          "cmp_docs",
          "cmp_menu",
          "DressingInput",
          "lazy",
          "mason",
          "noice",
          "notify",
          "prompt",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_picker_input",
          "TelescopePrompt",
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          handle = true,
          search = false,
          ale = false,
        },
      })

      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
}
