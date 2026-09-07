return {
  "yetone/avante.nvim",
  -- 如果您想从源代码构建，请执行 `make BUILD_FROM_SOURCE=true`
  -- ⚠️ 一定要加上这一行配置！！！！！
  build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  version = false, -- 永远不要将此值设置为 "*"！永远不要！
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- 以下依赖项是可选的，
    -- "echasnovski/mini.pick", -- 用于文件选择器提供者 mini.pick
    "nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
    "nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- 用于 providers='copilot'
    {
      -- 如果您有 lazy=true，请确保正确设置
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    instructions_file = "avante.md",
    -- 在此处添加任何选项
    -- provider = "copilot",
    -- provider = "openai",
    -- provider = "claude",
    provider = "codex",

    -- 控制「工具使用」的權限提示：
    -- true  = 全部自動允許（不提示）
    -- false = 每次都要確認
    behaviour = {
      auto_approve_tool_permissions = false,
    },

    auto_suggestions_provider = "copilot",
    providers = {
      openai = {
        endpoint = "https://api.githubcopilot.com",
        model = "gpt-5.5",
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
          -- reasoning_effort = "high" -- 僅支援推理模型 (o1 等)
        },
      },
    },

    -- 使用 `provider = "codex"` 需要啟用 ACP，並能執行 codex 的 ACP agent（下方用 npx）
    acp_providers = {
      ["codex"] = {
        -- 用 npx 執行，不需要全域安裝 codex-acp（二進位會快取到 ~/.npm）
        command = "npx",
        args = { "-y", "@zed-industries/codex-acp" },
        env = {
          NODE_NO_WARNINGS = "1",
          HOME = os.getenv("HOME"),
          PATH = os.getenv("PATH"),
          -- 不使用 OpenAI API Key（sk-...），改用 `codex login` 存在 ~/.codex/auth.json 的登入憑證
        },
      },
    },
  },
}
