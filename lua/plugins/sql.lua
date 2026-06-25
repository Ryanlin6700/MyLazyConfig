local sql_ft = { "sql", "mysql", "plsql" }

local function add_unique(list, item)
  if not vim.tbl_contains(list, item) then
    table.insert(list, item)
  end
end

return {
  {
    "LazyVim/LazyVim",
    init = function()
      vim.g.omni_sql_no_default_maps = 1

      vim.api.nvim_create_autocmd("FileType", {
        pattern = sql_ft,
        callback = function(args)
          vim.b[args.buf].autoformat = false
          vim.bo[args.buf].commentstring = "-- %s"
          vim.keymap.set("i", "<C-x><C-o>", "<Nop>", {
            buffer = args.buf,
            desc = "Disable SQL omni completion",
          })

          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              vim.bo[args.buf].omnifunc = ""
            end
          end)
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sqls = {
          filetypes = sql_ft,
          single_file_support = true,
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, "sql")
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}

      opts.sources.providers.dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
      }

      for _, ft in ipairs(sql_ft) do
        opts.sources.per_filetype[ft] = opts.sources.per_filetype[ft] or {}
        opts.sources.per_filetype[ft].inherit_defaults = true
        add_unique(opts.sources.per_filetype[ft], "dadbod")
      end
    end,
  },
}
