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
          accept = "<C-CR>",
          accept_word = "<C-Right>",
          accept_line = "<C-l>",
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-e>",
        },
      },
    })
  end,
}
