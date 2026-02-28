-- plugins/flash.lua
return 
{
  "folke/flash.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
  keys = {
    -- S 키로 treesitter 노드 점프 모드 진입
    { "S", mode = { "n", "x", "o" },
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter" },
  },
}
