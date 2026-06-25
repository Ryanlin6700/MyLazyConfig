-- 修改 LazyVim 原本的 <leader>d / <leader>dp group
return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}

      local function replace_leader_groups(spec)
        for i = #spec, 1, -1 do
          local item = spec[i]
          if type(item) == "table" then
            if type(item[1]) == "string" then
              if item[1] == "<leader>d" then
                item.group = "database"
              elseif item[1] == "<leader>dp" then
                table.remove(spec, i)
              end
            else
              replace_leader_groups(item)
            end
          end
        end
      end

      replace_leader_groups(opts.spec)

      table.insert(opts.spec, {
        mode = { "n", "x" },
        { "<leader>D", group = "debug" },
        { "<leader>Dp", group = "profiler" },
      })
    end,
  },
}
