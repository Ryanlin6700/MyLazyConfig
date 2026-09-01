-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
vim.g.mapleader = " "
vim.g.markdown_syntax_conceal = 1
vim.opt.timeoutlen = 500

-- Use Copilot's native inline suggestions instead of routing them through blink.cmp.
vim.g.ai_cmp = false

local function wsl_clipboard_without_exe()
  local osc52 = require("vim.ui.clipboard.osc52")
  local cache = {
    ["+"] = { {}, "v" },
    ["*"] = { {}, "v" },
  }
  local copied_at = {
    ["+"] = 0,
    ["*"] = 0,
  }

  local function xclip_selection(reg)
    return reg == "+" and "clipboard" or "primary"
  end

  local function copy(reg)
    local osc52_copy = osc52.copy(reg)

    return function(lines, regtype)
      cache[reg] = { lines, regtype }
      copied_at[reg] = vim.uv.hrtime()
      osc52_copy(lines)

      if vim.fn.executable("xclip") == 1 and vim.env.DISPLAY then
        local job = vim.fn.jobstart({ "xclip", "-quiet", "-i", "-selection", xclip_selection(reg) }, {
          cwd = "/",
          detach = true,
        })

        if job > 0 then
          vim.fn.jobsend(job, lines)
          vim.fn.jobclose(job, "stdin")
          vim.fn.jobclose(job, "stdout")
        end
      end
    end
  end

  local function paste(reg)
    return function()
      if vim.uv.hrtime() - copied_at[reg] < 2 * 1000 * 1000 * 1000 then
        return cache[reg]
      end

      if vim.fn.executable("xclip") == 1 and vim.env.DISPLAY then
        local lines = vim.fn.systemlist({ "xclip", "-o", "-selection", xclip_selection(reg) }, "", 1)

        if vim.v.shell_error == 0 then
          if vim.deep_equal(lines, cache[reg][1]) then
            return cache[reg]
          end

          return { lines, "v" }
        end
      end

      return cache[reg]
    end
  end

  vim.g.clipboard = {
    name = "WindowsTerminalOSC52",
    copy = {
      ["+"] = copy("+"),
      ["*"] = copy("*"),
    },
    paste = {
      ["+"] = paste("+"),
      ["*"] = paste("*"),
    },
    cache_enabled = 0,
  }
end

-- In Windows Terminal, xclip can stay local to WSLg and not update the Windows
-- clipboard. OSC52 writes directly to the terminal clipboard without .exe.
if vim.fn.has("wsl") == 1 and vim.env.WT_SESSION then
  wsl_clipboard_without_exe()
elseif vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 and vim.env.WAYLAND_DISPLAY then
  vim.g.clipboard = "wl-copy"
elseif vim.fn.executable("xclip") == 1 and vim.env.DISPLAY then
  vim.g.clipboard = "xclip"
elseif vim.fn.has("wsl") == 1 then
  vim.g.clipboard = "osc52"
end

vim.opt.clipboard:append("unnamedplus")

-- Make external picker tools available even when Neovim is launched from a GUI
-- or another environment with a minimal PATH.
do
  local path_sep = package.config:sub(1, 1) == "\\" and ";" or ":"
  local paths = {
    vim.fn.stdpath("config") .. "/bin",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    vim.fn.expand("~/.local/bin"),
    vim.fn.expand("~/.cargo/bin"),
    vim.fn.expand("~/go/bin"),
    "/opt/homebrew/bin",
    "/home/linuxbrew/.linuxbrew/bin",
  }
  local current = path_sep .. (vim.env.PATH or "") .. path_sep

  for i = #paths, 1, -1 do
    local dir = paths[i]
    if vim.fn.isdirectory(dir) == 1 and not current:find(path_sep .. vim.pesc(dir) .. path_sep) then
      vim.env.PATH = dir .. path_sep .. (vim.env.PATH or "")
      current = path_sep .. vim.env.PATH .. path_sep
    end
  end
end

vim.api.nvim_set_hl(0, "swagger_tag", { fg = "#FFD700", bold = true })

-- Apply early so native gc/gcc uses this behavior from startup.
-- Go: keep blank lines blank when toggling comments.
if not vim.g.go_comment_skip_blank_patched then
  local ok, native_comment = pcall(require, "vim._comment")
  if ok and native_comment and type(native_comment.operator) == "function" then
    for i = 1, 20 do
      local name, original_toggle_lines = debug.getupvalue(native_comment.operator, i)
      if name == "toggle_lines" and type(original_toggle_lines) == "function" then
        local function toggle_lines_skip_go_blank(line_start, line_end, ref_position)
          if vim.bo.filetype ~= "go" then
            return original_toggle_lines(line_start, line_end, ref_position)
          end

          local before = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
          local blank_lines = {}
          local has_blank = false

          for idx, line in ipairs(before) do
            if line:match("^%s*$") then
              blank_lines[idx] = line
              has_blank = true
            end
          end

          original_toggle_lines(line_start, line_end, ref_position)

          if not has_blank then
            return
          end

          local after = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
          local changed = false

          for idx = 1, #after do
            if blank_lines[idx] ~= nil and after[idx] ~= blank_lines[idx] then
              after[idx] = blank_lines[idx]
              changed = true
            end
          end

          if changed then
            vim._with({ lockmarks = true }, function()
              vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, after)
            end)
          end
        end

        debug.setupvalue(native_comment.operator, i, toggle_lines_skip_go_blank)
        native_comment.toggle_lines = toggle_lines_skip_go_blank
        vim.g.go_comment_skip_blank_patched = true
        break
      end
    end
  end
end
