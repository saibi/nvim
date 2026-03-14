# Neovim Keymaps

> 자동 생성: 2026-03-14
> `python3 gen_keymaps.py --nvim-dir /Users/saibi/.config/nvim` 로 재생성

## Normal Mode

| 키           | 설명                     | 출처                     |
| ------------ | ------------------------ | ------------------------ |
| `-`          | netrw 열기               | init.lua                 |
| `<leader>ff` | Telescope find files     | init.lua                 |
| `<leader>fg` | Telescope live grep      | init.lua                 |
| `<leader>fb` | Telescope buffers        | init.lua                 |
| `<leader>fh` | Telescope help tags      | init.lua                 |
| `<leader>e`  | —                        | init.lua                 |
| `g>`         | 다음 진단으로            | init.lua                 |
| `g<`         | 이전 진단으로            | init.lua                 |
| `gs`         | —                        | init.lua                 |
| `<leader>cc` | Copilot Chat 토글        | plugins/copilot-chat.lua |
| `gd`         | 정의로 이동 (LSP)        | plugins/lsp.lua          |
| `gr`         | 참조 목록 (LSP)          | plugins/lsp.lua          |
| `K`          | 호버 정보 (LSP)          | plugins/lsp.lua          |
| `<leader>rn` | 이름 변경 (LSP)          | plugins/lsp.lua          |
| `gD`         | 선언으로 이동 (LSP)      | plugins/lsp.lua          |
| `gl`         | 구현으로 이동 (LSP)      | plugins/lsp.lua          |
| `gh`         | 시그니처 도움말 (LSP)    | plugins/lsp.lua          |
| `<leader>gh` | —                        | plugins/lsp.lua          |
| `<leader>tc` | Toggle TS Context        | plugins/treesitter.lua   |
| `[x`         | Jump to context (upward) | plugins/treesitter.lua   |
| `<leader>sp` | TS swap next param       | plugins/treesitter.lua   |
| `<leader>sP` | TS swap prev param       | plugins/treesitter.lua   |
| `<leader>u`  | —                        | plugins/undotree.lua     |

## Insert Mode

| 키          | 설명                     | 출처                |
| ----------- | ------------------------ | ------------------- |
| `<Tab>`     | 제안 전체 수락 (Copilot) | plugins/copilot.lua |
| `<C-Right>` | 단어 단위 수락 (Copilot) | plugins/copilot.lua |
| `<C-l>`     | 줄 단위 수락 (Copilot)   | plugins/copilot.lua |
| `<C-j>`     | 다음 제안 (Copilot)      | plugins/copilot.lua |
| `<C-k>`     | 이전 제안 (Copilot)      | plugins/copilot.lua |
| `<C-e>`     | 제안 닫기 (Copilot)      | plugins/copilot.lua |

## Normal / Visual Mode

| 키           | 설명                         | 출처                     |
| ------------ | ---------------------------- | ------------------------ |
| `<leader>ci` | Format buffer (or selection) | plugins/conform.lua      |
| `<leader>ce` | 코드 설명                    | plugins/copilot-chat.lua |
| `<leader>cr` | 코드 리뷰                    | plugins/copilot-chat.lua |
| `<leader>cf` | 코드 수정                    | plugins/copilot-chat.lua |

## Normal / Visual / Operator Mode

| 키  | 설명             | 출처              |
| --- | ---------------- | ----------------- |
| `S` | Flash Treesitter | plugins/flash.lua |

