return {
  "zbirenbaum/copilot.lua",
  enabled = false,
  event = "InsertEnter",
  cmd = "Copilot",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-CR>",
          accept_word = "<C-Right>",
          accept_line = "<C-l>",
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
    })

    -- copilot highlight.lua 가 vim.schedule 로 설정하므로 그 이후에 덮어씀
    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { ctermfg = 244, italic = true })
    end)
  end,
}
