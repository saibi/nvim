return {
  "suiramdev/cursorcli.nvim",
  event = "VeryLazy",
  config = function()
    require("cursorcli").setup({
      command = { "agent" },
    })
  end,
  keys = {
    { "<leader>uf", "<cmd>CursorCliOpenWithLayout float<cr>",  desc = "Cursor agent (float)" },
    { "<leader>uv", "<cmd>CursorCliOpenWithLayout vsplit<cr>", desc = "Cursor agent (vsplit)" },
    { "<leader>uh", "<cmd>CursorCliOpenWithLayout hsplit<cr>", desc = "Cursor agent (hsplit)" },
    { "<leader>us", function() require("cursorcli").select_chat() end, desc = "Cursor agent 채팅 선택" },
    { "<leader>ue", "<cmd>CursorCliFixErrorAtCursor<cr>",      desc = "Cursor agent 에러 수정" },
    { "<leader>ua", "<cmd>CursorCliAddVisualSelectionToNewSession<cr>", desc = "Cursor agent 선택 코드 전송", mode = { "n", "v" } },
  },
}
