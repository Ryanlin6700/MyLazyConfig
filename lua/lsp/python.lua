local lspconfig = require("lspconfig")

-- 自動偵測專案根目錄下的 .venv
local function get_python_path(workspace)
  -- 如果有 VIRTUAL_ENV，優先使用
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end

  -- 專案目錄的 .venv
  local cwd = vim.fn.getcwd()
  local venv_python = cwd .. "/.venv/bin/python"
  if vim.fn.executable(venv_python) == 1 then
    return venv_python
  end

  -- fallback: 系統 python
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    -- 你可以在這裡綁定快捷鍵
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end,
})
