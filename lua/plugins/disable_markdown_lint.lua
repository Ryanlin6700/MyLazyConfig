return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      if not opts.sources then
        return
      end
      opts.sources = vim.tbl_filter(function(src)
        return src.name ~= "markdownlint_cli2"
      end, opts.sources)
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = nil
      opts.linters_by_ft["markdown.mdx"] = nil
    end,
  },
}
