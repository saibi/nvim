return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>ci",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer (or selection)",
    },
  },
  opts = {
    format_on_save = false,

    formatters_by_ft = {
      javascript      = { "prettierd", "prettier", stop_after_first = true },
      typescript      = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      css             = { "prettierd", "prettier", stop_after_first = true },
      html            = { "prettierd", "prettier", stop_after_first = true },
      json            = { "prettierd", "prettier", stop_after_first = true },
      yaml            = { "prettierd", "prettier", stop_after_first = true },
      markdown        = { "prettierd", "prettier", stop_after_first = true },
      python          = { "ruff_format", "black", stop_after_first = true },
      lua             = { "stylua" },
      c               = { "clang_format" },
      cpp             = { "clang_format" },
      go              = { "gofmt", "goimports", stop_after_first = true },
      rust            = { "rustfmt" },
      sh              = { "shfmt" },
      bash            = { "shfmt" },
      zsh             = { "shfmt" },
    },

    formatters = {
      shfmt = {
        prepend_args = { "-i", "4" },
      },
      clang_format = {
        prepend_args = { "--style=file" },
      },
    },
  },
}

-- Install formatter (using Mason)
-- :MasonInstall prettierd stylua ruff black clang-format goimports shfmt
