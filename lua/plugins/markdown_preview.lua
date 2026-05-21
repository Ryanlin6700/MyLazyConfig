local function is_wsl()
  if vim.fn.has("wsl") == 1 then
    return true
  end

  local uname = vim.loop.os_uname()
  local release = (uname and uname.release or ""):lower()
  return release:find("microsoft", 1, true) ~= nil or vim.env.WSL_DISTRO_NAME ~= nil
end

local function open_markdown_preview_wsl(url)
  local commands = {
    { "cmd.exe", "/d", "/c", "start", '""', url },
    { "powershell.exe", "-NoProfile", "-Command", "Start-Process", url },
    { "wslview", url },
    { "explorer.exe", url },
  }

  for _, command in ipairs(commands) do
    if vim.fn.executable(command[1]) == 1 then
      local job = vim.fn.jobstart(command, { detach = true })
      if job > 0 then
        return
      end
    end
  end

  vim.notify("markdown-preview.nvim: unable to open browser from WSL", vim.log.levels.ERROR)
end

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  init = function()
    if is_wsl() then
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_browserfunc = "OpenMarkdownPreviewWsl"
      vim.g.mkdp_echo_preview_url = 1
      _G.OpenMarkdownPreviewWsl = open_markdown_preview_wsl
      vim.cmd([[
        function! OpenMarkdownPreviewWsl(url) abort
          call v:lua.OpenMarkdownPreviewWsl(a:url)
        endfunction
      ]])
    end
  end,
  build = function()
    vim.fn["mkdp#util#install_sync"](true)
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
