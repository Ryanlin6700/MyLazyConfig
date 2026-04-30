-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- Normal 模式 Ctrl-/ => 等同 gc
vim.keymap.set("n", "<leader>/", "Vgc", { remap = true, silent = true })
-- vim.keymap.set("n", "<leader>/", function()
--   local line = vim.api.nvim_get_current_line()
--
--   -- 若是空白或只有空白字元 → 返回（不註解）
--   if line:match("^%s*$") then
--     return
--   end
--
--   -- 不是空白 → 執行選取+gc 註解
--   vim.api.nvim_feedkeys("Vgc", "n", false)
-- end, { silent = true })

-- Visual 模式 Ctrl-/ => 等同 gc 選取
vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true })

vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- 清除搜尋高亮
vim.keymap.set("n", "<leader>h", ":noh<CR>")

-- 返回Normal 模式
vim.api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<ESC>", { noremap = false })

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "snacks_picker_input",
--   callback = function(args)
--     -- Avoid global `jj`/`jk` insert mappings delaying Snacks picker navigation.
--     vim.keymap.set({ "i", "n" }, "j", "<Down>", {
--       buffer = args.buf,
--       remap = true,
--       silent = true,
--       nowait = true,
--     })
--     vim.keymap.set({ "i", "n" }, "k", "<Up>", {
--       buffer = args.buf,
--       remap = true,
--       silent = true,
--       nowait = true,
--     })
--   end,
-- })

-- 關閉所有 LSP 的 inlay hints（LazyVim 預設有啟用）
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false)
    end
  end,
})

-- Tab pages
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>ts", "<cmd>tab split<CR>", { desc = "Tab Split" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Tab Only" })
