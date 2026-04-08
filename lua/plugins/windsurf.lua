return {
  "Exafunction/windsurf.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "InsertEnter",
  cmd = { "Codeium" },
  config = function()
    require("codeium").setup({
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 75,
        key_bindings = {
          accept = "<C-SPACE>",
          accept_word = "<C-Right>",
          accept_line = "<C-l>",
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-e>",
        },
      },
    })

    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CodeiumSuggestion", { ctermfg = 244, italic = true })
    end)
  end,
}
