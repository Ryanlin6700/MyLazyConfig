return {
  {
    "vimpostor/vim-tpipeline",
    dependencies = { "nvim-lualine/lualine.nvim" },
    init = function()
      -- tmux decides whether to show its native status or the Neovim bridge.
      vim.g.tpipeline_autoembed = 0
      vim.g.tpipeline_restore = 0
      vim.g.tpipeline_clearstl = 1
      vim.g.tpipeline_cursormoved = 0
    end,
    config = function()
      local frozen_reasons = {}
      local nvim_focused = true
      local refresh_timer

      local function call_tpipeline(fn)
        pcall(vim.fn["tpipeline#state#" .. fn])
      end

      local function is_frozen()
        return next(frozen_reasons) ~= nil
      end

      local function keep_internal_statusline_hidden()
        vim.o.laststatus = 0
        vim.o.ruler = false
      end

      local function refresh_embedded_statusline(allow_while_frozen)
        local sync = function()
          keep_internal_statusline_hidden()

          if is_frozen() and not allow_while_frozen then
            return
          end

          local ok, lualine = pcall(require, "lualine")
          if ok then
            pcall(lualine.refresh, {
              scope = "window",
              place = { "statusline" },
              force = true,
            })
          end

          pcall(vim.fn["tpipeline#lualine#fix_stl"])
          keep_internal_statusline_hidden()
        end

        vim.schedule(sync)
      end

      local function stop_refresh_timer()
        if not refresh_timer then
          return
        end

        refresh_timer:stop()
        if not refresh_timer:is_closing() then
          refresh_timer:close()
        end
        refresh_timer = nil
      end

      local function start_refresh_timer()
        stop_refresh_timer()

        local uv = vim.uv or vim.loop
        refresh_timer = uv.new_timer()

        -- Refresh just after the next minute boundary, then once per minute.
        local seconds = tonumber(os.date("%S")) or 0
        local first_refresh = (60 - seconds) * 1000 + 100
        refresh_timer:start(
          first_refresh,
          60 * 1000,
          vim.schedule_wrap(function()
            if nvim_focused then
              -- A low-frequency heartbeat is allowed through the anti-flicker freeze.
              refresh_embedded_statusline(true)
            end
          end)
        )
      end

      local function matching_window_visible(matches)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ok, matched = pcall(matches, buf)

            if ok and matched then
              return true
            end
          end
        end

        return false
      end

      local function dadbod_window_visible()
        return matching_window_visible(function(buf)
          local filetype = vim.bo[buf].filetype
          return filetype == "dbui" or filetype == "dbout"
        end)
      end

      local function terminal_window_visible()
        return matching_window_visible(function(buf)
          if vim.bo[buf].buftype ~= "terminal" then
            return false
          end

          local job_id = vim.b[buf].terminal_job_id
          if type(job_id) ~= "number" then
            return true
          end

          local ok, status = pcall(vim.fn.jobwait, { job_id }, 0)
          return not ok or status[1] == -1
        end)
      end

      local function freeze_for(reason)
        frozen_reasons[reason] = true
        keep_internal_statusline_hidden()
        call_tpipeline("freeze")
      end

      local function thaw_for(reason)
        if not frozen_reasons[reason] then
          return
        end

        frozen_reasons[reason] = nil

        if is_frozen() then
          keep_internal_statusline_hidden()
          return
        end

        call_tpipeline("thaw")
        refresh_embedded_statusline()
      end

      local function freeze_for_dadbod()
        freeze_for("dadbod")
      end

      local function sync_dadbod_state()
        vim.schedule(function()
          if dadbod_window_visible() then
            freeze_for_dadbod()
          else
            thaw_for("dadbod")
          end
        end)
      end

      local function freeze_for_terminal()
        freeze_for("terminal")
      end

      local function sync_terminal_state()
        vim.schedule(function()
          if terminal_window_visible() then
            freeze_for_terminal()
          else
            thaw_for("terminal")
          end
        end)
      end

      local group = vim.api.nvim_create_augroup("tpipeline_no_flicker", { clear = true })

      vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = function()
          nvim_focused = true
          refresh_embedded_statusline(true)
        end,
      })

      vim.api.nvim_create_autocmd("FocusLost", {
        group = group,
        callback = function()
          nvim_focused = false
        end,
      })

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
        callback = function()
          sync_dadbod_state()
          sync_terminal_state()
        end,
      })

      vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
        group = group,
        callback = freeze_for_terminal,
      })

      vim.api.nvim_create_autocmd("TermClose", {
        group = group,
        callback = sync_terminal_state,
      })

      vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        pattern = "*",
        callback = function(event)
          local old_mode, new_mode = event.match:match("([^:]*):(.+)")
          old_mode = old_mode or ""
          new_mode = new_mode or ""

          if new_mode:sub(1, 1) == "t" then
            freeze_for_terminal()
          elseif old_mode:sub(1, 1) == "t" then
            sync_terminal_state()
          end
        end,
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
          stop_refresh_timer()
          if is_frozen() then
            pcall(vim.fn["tpipeline#cleanup"])
          end
        end,
      })

      start_refresh_timer()
      refresh_embedded_statusline(true)
    end,
  },
}
