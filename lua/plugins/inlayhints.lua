-- 變數提示預設值設定
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false, -- 預設關閉
      },
      setup = {
        ["*"] = function(_, config)
          -- 透過 LspAttach 事件取得 client 物件
          vim.schedule(function()
            local clients = vim.lsp.get_active_clients()
            for _, client in ipairs(clients) do
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint(client.id, false)
              end
            end
          end)
        end,
      },
    },
  },
}
