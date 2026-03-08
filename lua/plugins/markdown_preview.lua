return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
    vim.g.mkdp_theme = "light"
  end,
  config = function()
    -- 快捷鍵設定
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>mp", "<Cmd>MarkdownPreview<CR>", opts) -- 開啟
    vim.keymap.set("n", "<leader>mt", "<Cmd>MarkdownPreviewToggle<CR>", opts) -- 切換
    vim.keymap.set("n", "<leader>ms", "<Cmd>MarkdownPreviewStop<CR>", opts) -- 停止
  end,
}
