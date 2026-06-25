return {
  {
    "vimpostor/vim-tpipeline",
    dependencies = { "nvim-lualine/lualine.nvim" },
    init = function()
      -- Let tpipeline replace tmux status-left/right only while Neovim is active.
      vim.g.tpipeline_autoembed = 1
      vim.g.tpipeline_restore = 1
      vim.g.tpipeline_clearstl = 1
    end,
    config = function()
      local frozen_for_dadbod = false

      local function call_tpipeline(fn)
        pcall(vim.fn["tpipeline#state#" .. fn])
      end

      local function keep_internal_statusline_hidden()
        vim.o.laststatus = 0
        vim.o.ruler = false
      end

      local function refresh_embedded_statusline()
        local sync = function()
          keep_internal_statusline_hidden()
          pcall(vim.fn["tpipeline#lualine#fix_stl"])
          pcall(vim.fn["tpipeline#update"])
          keep_internal_statusline_hidden()
        end

        vim.schedule(sync)
        vim.defer_fn(sync, 30)
      end

      local function dadbod_window_visible()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ok, filetype = pcall(function()
              return vim.bo[buf].filetype
            end)

            if ok and (filetype == "dbui" or filetype == "dbout") then
              return true
            end
          end
        end

        return false
      end

      local function freeze_for_dadbod()
        frozen_for_dadbod = true
        keep_internal_statusline_hidden()
        call_tpipeline("freeze")
      end

      local function sync_dadbod_state()
        vim.schedule(function()
          if dadbod_window_visible() then
            freeze_for_dadbod()
          elseif frozen_for_dadbod then
            frozen_for_dadbod = false
            call_tpipeline("thaw")
          end
        end)
      end

      local group = vim.api.nvim_create_augroup("tpipeline_dadbod_no_flicker", { clear = true })

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "DBQueryPre", "*DBExecutePre" },
        callback = freeze_for_dadbod,
      })

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "DBQueryPost", "*DBExecutePost" },
        callback = sync_dadbod_state,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "dbui", "dbout" },
        callback = freeze_for_dadbod,
      })

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave", "WinClosed" }, {
        group = group,
        callback = sync_dadbod_state,
      })

      vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "TermLeave" }, {
        group = group,
        callback = refresh_embedded_statusline,
      })

      vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        pattern = "*",
        callback = function(event)
          local old_mode, new_mode = event.match:match("([^:]*):(.+)")
          old_mode = old_mode or ""
          new_mode = new_mode or ""

          if old_mode:sub(1, 1) == "t" or new_mode:sub(1, 1) == "t" then
            refresh_embedded_statusline()
          end
        end,
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
          if frozen_for_dadbod then
            pcall(vim.fn["tpipeline#cleanup"])
          end
        end,
      })
    end,
  },
}
