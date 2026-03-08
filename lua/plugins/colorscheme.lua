return {
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    "catppuccin/nvim",
    "vague-theme/vague.nvim",
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-moon",
    },
  },
}
