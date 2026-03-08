-- 自訂 LazyVim 插件：高亮 Go Swagger 註解
-- 放在 ~/.config/nvim/lua/plugins/swagger-highlight.lua

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 確保 Go 語法已啟用
      if not vim.tbl_contains(opts.ensure_installed, "go") then
        table.insert(opts.ensure_installed, "go")
      end

      -- 定義 Swagger query
      local query = [[
        ;; 高亮 Go 單行註解中的 Swagger 標籤
        ((line_comment) @swagger_tag
          (#match? @swagger_tag "@Summary|@Description|@Tags|@Accept|@Produce|@Param|@Success|@Failure|@Router|@Security"))

        ;; 高亮 Go 區塊註解中的 Swagger 標籤
        ((comment_block) @swagger_tag
          (#match? @swagger_tag "@Summary|@Description|@Tags|@Accept|@Produce|@Param|@Success|@Failure|@Router|@Security"))
      ]]

      local query_path = vim.fn.stdpath("config") .. "/after/queries/go"
      vim.fn.mkdir(query_path, "p")
      local f = io.open(query_path .. "/highlights.scm", "w")
      if f then
        f:write(query)
        f:close()
      end

      -- 延遲設定顏色，確保 Treesitter 已載入
      vim.schedule(function()
        vim.api.nvim_set_hl(0, "swagger_tag", { fg = "#FFD700", bold = true })
      end)
    end,
  },
}
