return {
  "suiramdev/cursorcli.nvim",
  event = "VeryLazy",
  config = function()
    require("cursorcli").setup({
      command = { "agent" },
    })
  end,
  keys = {
    { "<leader>AF", "<cmd>CursorCliOpenWithLayout float<cr>",  desc = "Cursor agent (float)" },
    { "<leader>AV", "<cmd>CursorCliOpenWithLayout vsplit<cr>", desc = "Cursor agent (vsplit)" },
    { "<leader>AH", "<cmd>CursorCliOpenWithLayout hsplit<cr>", desc = "Cursor agent (hsplit)" },
    { "<leader>AS", function() require("cursorcli").select_chat() end, desc = "Cursor agent 채팅 선택" },
    { "<leader>AE", "<cmd>CursorCliFixErrorAtCursor<cr>",      desc = "Cursor agent 에러 수정" },
    { "<leader>AA", "<cmd>CursorCliAddVisualSelectionToNewSession<cr>", desc = "Cursor agent 선택 코드 전송", mode = { "n", "v" } },
  },
}
