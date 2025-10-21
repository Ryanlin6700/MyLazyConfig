-- gopls + lspsaga + telescope + aerial 組合
local lspconfig = require("lspconfig")

-- 啟用 Go LSP
lspconfig.gopls.setup({
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
  on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, silent = true }
    local map = vim.keymap.set

    -- LSP 基本功能
    map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- 顯示 func / doc 浮窗
    map("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- 彈窗預覽函數定義
    map("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- 查看引用
    map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- 查看實作
    map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- 顯示可修正動作
    map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- 重命名符號
    map("n", "<leader>a", "<cmd>AerialToggle!<CR>", opts) -- 切換側邊函數大綱
  end,
})
