return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "zbirenbaum/copilot.lua",
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  opts = {
    language = "Korean",  -- 응답 언어
  },
  keys = {
    { "<leader>cc", "<cmd>CopilotChatToggle<cr>",  desc = "Copilot Chat 토글" },
    { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "코드 설명", mode = { "n", "v" } },
    { "<leader>cr", "<cmd>CopilotChatReview<cr>",  desc = "코드 리뷰",  mode = { "n", "v" } },
    { "<leader>cf", "<cmd>CopilotChatFix<cr>",     desc = "코드 수정",  mode = { "n", "v" } },
  },
}
