-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- Normal 模式 Ctrl-/ => 等同 gc
vim.keymap.set("n", "<leader>/", "Vgc", { remap = true, silent = true })

-- Visual 模式 Ctrl-/ => 等同 gc 選取
vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true })

vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- 返回Normal 模式
vim.api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<ESC>", { noremap = false })
