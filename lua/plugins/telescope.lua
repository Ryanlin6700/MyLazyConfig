return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.layout_strategy = "horizontal"
      opts.defaults.layout_config = {
        width = 0.95,
        height = 0.85,
        preview_cutoff = 1, -- ⭐ 強制永遠顯示 preview
        horizontal = {
          preview_width = 0.8,
          results_width = 0.2,
        },
      }
    end,
  },
}
