return {
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      opts.suggestion = vim.tbl_deep_extend("force", opts.suggestion or {}, {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<Tab>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      })
      opts.panel = vim.tbl_deep_extend("force", opts.panel or {}, {
        enabled = false,
      })
      opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes or {}, {
        markdown = true,
        help = true,
        html = true,
        javascript = true,
        typescript = true,
        ["*"] = true,
      })
    end,
  },
}
