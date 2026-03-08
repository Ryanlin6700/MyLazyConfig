return {
  {
    "isakbm/gitgraph.nvim",
    opts = {
      git_cmd = "git",
      symbols = {
        merge_commit = "M",
        commit = "*",
      },
      format = {
        timestamp = "%H:%M:%S %d-%m-%Y",
        fields = { "hash", "timestamp", "author", "branch_name", "tag", "head" },
      },
      hooks = {
        on_select_commit = function(commit)
          print("selected commit:", commit.hash)
        end,
        on_select_range_commit = function(from, to)
          print("selected range:", from.hash, to.hash)
        end,
      },
    },
    keys = {
      {
        "<leader>gv",
        function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end,
        desc = "GitGraph - Draw",
      },
    },
  },
}
-- return {
--   {
--     "isakbm/gitgraph.nvim",
--     -- @type I.GGConfig
--     ---@type snacks.Config
--     opts = {
--       symbols = {
--         merge_commit = "M",
--         commit = "*",
--       },
--       format = {
--         timestamp = "%H:%M:%S %d-%m-%Y",
--         fields = { "hash", "timestamp", "author", "branch_name", "tag", "head" },
--       },
--       hooks = {
--         -- 當選擇 commit 時執行的動作 (可選)
--         on_select_commit = function(commit)
--           print("selected commit:", commit.hash)
--         end,
--         on_select_range_commit = function(from, to)
--           print("selected range:", from.hash, to.hash)
--         end,
--       },
--     },
--     keys = {
--       {
--         "<leader>gv",
--         function()
--           -- 使用 Snacks.win 建立浮動視窗
--           Snacks.win({
--             position = "float",
--             width = 0.5, -- 視窗寬度佔 90%
--             height = 0.9, -- 視窗高度佔 90%
--             border = "rounded", -- 邊框樣式
--             title = "Git Graph",
--             title_pos = "center",
--             enter = true, -- 建立後自動進入視窗
--             focusable = true,
--             -- keys = {
--             --   -- q = function(win)
--             --   --   win:close()
--             --   -- end,
--             --   ["<Esc>"] = function(win)
--             --     win:close()
--             --   end,
--             --   ["<leader>wd"] = function(win)
--             --     win:close()
--             --   end,
--             -- },
--             -- 視窗建立後的動作
--             -- on_win = function(win)
--             --   require("gitgraph").draw({}, { all = true, max_count = 5000 })
--             --
--             --   -- vim.keymap.set("n", "<leader>wd", "q")
--             -- end,
--           })
--         end,
--         desc = "GitGraph - Draw",
--       },
--     },
--   },
-- }
