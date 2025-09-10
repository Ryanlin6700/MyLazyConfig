-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- <BS>-- 例如用 <Esc> 退出 terminal-insert
vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- Normal 模式 Ctrl-/ => 等同 gc
vim.keymap.set("n", "<C-/>", "Vgc", { remap = true, silent = true })
-- Visual 模式 Ctrl-/ => 等同 gc 選取
vim.keymap.set("x", "<C-/>", "gc", { remap = true, silent = true })
