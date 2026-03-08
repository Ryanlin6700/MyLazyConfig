-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
vim.g.mapleader = " "
vim.g.markdown_syntax_conceal = 1

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
