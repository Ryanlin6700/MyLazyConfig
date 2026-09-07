local function mask_connection_url(url)
  if type(url) ~= "string" then
    return vim.inspect(url)
  end

  return (url:gsub("([%w+.-]+://[^:/@%s]+:)[^@/%s]+@", "%1****@"))
end

local function add_connection(connections, name, url, source)
  if url == nil or url == "" then
    return
  end

  table.insert(connections, {
    name = tostring(name or "(unnamed)"),
    url = mask_connection_url(url),
    source = source,
  })
end

local function collect_dadbod_connections()
  local connections = {}
  local islist = vim.islist or vim.tbl_islist

  if type(vim.g.dbs) == "table" then
    if islist(vim.g.dbs) then
      for _, db in ipairs(vim.g.dbs) do
        if type(db) == "table" then
          add_connection(connections, db.name or db.url, db.url or db[1], "vim.g.dbs")
        else
          add_connection(connections, db, db, "vim.g.dbs")
        end
      end
    else
      for name, url in pairs(vim.g.dbs) do
        add_connection(connections, name, url, "vim.g.dbs")
      end
    end
  end

  local save_location = vim.g.db_ui_save_location or (vim.fn.stdpath("data") .. "/dadbod-ui")
  local connections_path = save_location .. "/connections.json"
  if vim.fn.filereadable(connections_path) ~= 1 then
    return connections
  end

  local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(connections_path), "\n"))
  if not ok or type(decoded) ~= "table" then
    vim.notify("Unable to read dadbod-ui connections.json", vim.log.levels.WARN)
    return connections
  end

  if islist(decoded) then
    for _, db in ipairs(decoded) do
      if type(db) == "table" then
        add_connection(connections, db.name or db.url, db.url, "dadbod-ui")
      end
    end
  else
    for name, url in pairs(decoded) do
      if type(url) == "table" then
        add_connection(connections, url.name or name, url.url, "dadbod-ui")
      else
        add_connection(connections, name, url, "dadbod-ui")
      end
    end
  end

  table.sort(connections, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  return connections
end

local function show_dadbod_connections()
  local connections = collect_dadbod_connections()
  if #connections == 0 then
    vim.notify("No dadbod connections found", vim.log.levels.INFO)
    return
  end

  local lines = { "Dadbod connections", "" }
  for _, db in ipairs(connections) do
    table.insert(lines, string.format("%s  [%s]", db.name, db.source))
    table.insert(lines, "  " .. db.url)
    table.insert(lines, "")
  end

  local width = math.min(vim.o.columns - 4, 110)
  local height = math.min(#lines, vim.o.lines - 6)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "text"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(row, 0),
    col = math.max(col, 0),
    border = "rounded",
    title = " DB DSNs ",
    title_pos = "center",
    style = "minimal",
  })

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
end

local function get_buffer_filetype(buf)
  local ok, filetype = pcall(function()
    return vim.bo[buf].filetype
  end)

  if ok then
    return filetype
  end

  return ""
end

local function close_windows_for_buffer(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function delete_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

local function close_dadbod_window()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_filetype = get_buffer_filetype(current_buf)
  local targets = {}

  local add_target = function(buf)
    targets[buf] = true
  end

  if current_filetype == "dbui" then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local filetype = get_buffer_filetype(buf)
      if filetype == "dbui" or filetype == "dbout" then
        add_target(buf)
      end
    end
  else
    add_target(current_buf)
  end

  for buf in pairs(targets) do
    close_windows_for_buffer(buf)
  end

  for buf in pairs(targets) do
    delete_buffer(buf)
  end
end

local function open_dadbod_item_in_right_split()
  pcall(vim.cmd, [[call db_ui#drawer#get().toggle_line('vertical botright split')]])
end

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
      "DBUIRenameBuffer",
      "DBUILastQueryInfo",
      "DBUIListConnections",
    },
    keys = {
      { "<leader>du", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
      { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "Database Add Connection" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Database Find Buffer" },
      { "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Database Rename Buffer" },
      { "<leader>dl", "<cmd>DBUIListConnections<cr>", desc = "Database List DSNs" },
    },
    init = function()
      -- Ensure lazy-loaded Dadbod can find the user-installed DuckDB CLI.
      vim.env.PATH = vim.fn.expand("~/.duckdb/cli/latest") .. ":" .. vim.env.PATH

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "right"

      -- SQLite's column output defaults to a width of 10 characters, which
      -- truncates longer names in the `Columns` table helper.  `.width` is a
      -- sqlite3 shell command, so it is applied before the helper's SELECT.
      local sqlite_columns_query = [[.width 6 24 16 10 24 6
SELECT * FROM pragma_table_info('{table}')]]
      vim.g.db_ui_table_helpers = vim.tbl_deep_extend("force", vim.g.db_ui_table_helpers or {}, {
        sqlite = { Columns = sqlite_columns_query },
        sqlite3 = { Columns = sqlite_columns_query },
      })

      local dadbod_ui_path = vim.fn.stdpath("data") .. "/dadbod-ui"
      vim.g.db_ui_save_location = dadbod_ui_path
      vim.g.db_ui_tmp_query_location = dadbod_ui_path .. "/queries"

      vim.fn.mkdir(vim.g.db_ui_save_location, "p")
      vim.fn.mkdir(vim.g.db_ui_tmp_query_location, "p")

      -- Add personal connections here, or run :DBUIAddConnection.
      -- Example:
      -- vim.g.dbs = {
      --   local_sqlite = "sqlite:/home/ryanlin/testDB.db",
      --   local_pg = "postgres://user:password@localhost:5432/dbname",
      --   local_mysql = "mysql://user:password@localhost:3306/dbname",
      -- }
    end,
    config = function()
      vim.api.nvim_create_user_command("DBUIListConnections", show_dadbod_connections, {
        desc = "List dadbod database connection DSNs",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "dbui", "dbout" },
        callback = function(event)
          vim.keymap.set("n", "q", close_dadbod_window, {
            buffer = event.buf,
            desc = "Close dadbod window",
            nowait = true,
            silent = true,
          })
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbui",
        callback = function(event)
          vim.keymap.set("n", "l", open_dadbod_item_in_right_split, {
            buffer = event.buf,
            desc = "Open dadbod item in split",
            nowait = true,
            silent = true,
          })
          vim.keymap.set("n", "<CR>", open_dadbod_item_in_right_split, {
            buffer = event.buf,
            desc = "Open dadbod item in split",
            silent = true,
          })
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set("n", "<leader>ds", "<Plug>(DBUI_SaveQuery)", {
            buffer = true,
            desc = "Database Save Query",
          })
          vim.keymap.set({ "n", "v" }, "<leader>dx", "<Plug>(DBUI_ExecuteQuery)", {
            buffer = true,
            desc = "Database Execute Query",
          })

          local ok, cmp = pcall(require, "cmp")
          if ok then
            cmp.setup.buffer({
              sources = cmp.config.sources({
                { name = "vim-dadbod-completion" },
              }, {
                { name = "buffer" },
              }),
            })
          end
        end,
      })
    end,
  },
}
