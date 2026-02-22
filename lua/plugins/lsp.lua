return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- 1. Mason 설정 (바이너리 관리)
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" },
      })

      -- 2. Neovim 0.11+ 스타일의 LSP 활성화
      -- 기존: require('lspconfig').clangd.setup({})
      -- 신규: vim.lsp.config를 통해 설정하거나 아래처럼 직접 활성화
      
      if vim.lsp.config then
          -- 최신 Neovim 0.11 방식
          vim.lsp.enable("clangd")
      else
          -- 하위 호환성을 위한 기존 방식 (v3.0.0 이전까지)
          require("lspconfig").clangd.setup({})
      end

      -- 3. LSP 단축키 (LspAttach 이벤트 사용)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local opts = { buffer = args.buf }

          -- 코드 탐색 단축키
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          
          -- clangd 전용 기능 (소스/헤더 스위칭)
          if client and client.name == "clangd" then
            vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
          end
        end,
      })
    end,
  },
}
