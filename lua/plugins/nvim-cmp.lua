-- override nvim-cmp and add cmp-emoji
return {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts table
  opts = function(_, opts)
    if opts.sources == nil then
      opts.sources = {}
    end
    table.insert(opts.sources, { name = "emoji" })
  end,
}
