# Neovim Keymaps

> 자동 생성: 2026-03-24
> `python3 gen_keymaps.py --nvim-dir /home/saibi/.config/nvim` 로 재생성

## Normal Mode

| 키                  | 설명                                                               | 출처                        |
| ------------------- | ------------------------------------------------------------------ | --------------------------- |
| `-`                 | netrw 열기                                                         | init.lua                    |
| `<leader>ff`        | Telescope find files                                               | init.lua                    |
| `<leader>fg`        | Telescope live grep                                                | init.lua                    |
| `<leader>fb`        | Telescope buffers                                                  | init.lua                    |
| `<leader>fh`        | Telescope help tags                                                | init.lua                    |
| `<leader>fs`        | Telescope LSP document symbols                                     | init.lua                    |
| `<leader>fS`        | Telescope LSP workspace symbols                                    | init.lua                    |
| `<leader>ft`        | Telescope current buffer tags                                      | init.lua                    |
| `<leader>fT`        | Telescope project tags                                             | init.lua                    |
| `<leader>e`         | —                                                                  | init.lua                    |
| `g>`                | 다음 진단으로                                                      | init.lua                    |
| `g<`                | 이전 진단으로                                                      | init.lua                    |
| `gs`                | 파일 확장자 반대 파일 점프                                         | init.lua                    |
| `<leader>a`         | AI/Claude Code                                                     | plugins/claudecode.lua      |
| `<leader>ac`        | Toggle Claude                                                      | plugins/claudecode.lua      |
| `<leader>af`        | Focus Claude                                                       | plugins/claudecode.lua      |
| `<leader>ar`        | Resume Claude                                                      | plugins/claudecode.lua      |
| `<leader>aC`        | Continue Claude                                                    | plugins/claudecode.lua      |
| `<leader>am`        | Select Claude model                                                | plugins/claudecode.lua      |
| `<leader>ab`        | Add current buffer                                                 | plugins/claudecode.lua      |
| `<leader>as`        | Add file                                                           | plugins/claudecode.lua      |
| `<leader>aa`        | Accept diff                                                        | plugins/claudecode.lua      |
| `<leader>ad`        | Deny diff                                                          | plugins/claudecode.lua      |
| `gcc`               | Toggles the current line using linewise comment                    | plugins/comment.lua         |
| `gbc`               | Toggles the current line using blockwise comment                   | plugins/comment.lua         |
| `[count]gcc`        | Toggles the number of line given as a prefix-count using linewise  | plugins/comment.lua         |
| `[count]gbc`        | Toggles the number of line given as a prefix-count using blockwise | plugins/comment.lua         |
| `gc[count]{motion}` | (Op-pending) Toggles the region using linewise comment             | plugins/comment.lua         |
| `gb[count]{motion}` | (Op-pending) Toggles the region using blockwise comment            | plugins/comment.lua         |
| `gco`               | Insert comment to the next line and enters INSERT mode             | plugins/comment.lua         |
| `gcO`               | Insert comment to the previous line and enters INSERT mode         | plugins/comment.lua         |
| `gcA`               | Insert comment to end of the current line and enters INSERT mode   | plugins/comment.lua         |
| `<leader>cc`        | Copilot Chat 토글                                                  | plugins/copilot-chat.lua    |
| `<leader>uf`        | Cursor agent (float)                                               | plugins/cursorcli.lua       |
| `<leader>uv`        | Cursor agent (vsplit)                                              | plugins/cursorcli.lua       |
| `<leader>uh`        | Cursor agent (hsplit)                                              | plugins/cursorcli.lua       |
| `<leader>us`        | Cursor agent 채팅 선택                                             | plugins/cursorcli.lua       |
| `<leader>ue`        | Cursor agent 에러 수정                                             | plugins/cursorcli.lua       |
| `gd`                | 정의로 이동 (LSP)                                                  | plugins/lsp.lua             |
| `gr`                | 참조 목록 (LSP)                                                    | plugins/lsp.lua             |
| `K`                 | 호버 정보 (LSP)                                                    | plugins/lsp.lua             |
| `<leader>rn`        | 이름 변경 (LSP)                                                    | plugins/lsp.lua             |
| `gD`                | 선언으로 이동 (LSP)                                                | plugins/lsp.lua             |
| `gl`                | 구현으로 이동 (LSP)                                                | plugins/lsp.lua             |
| `gh`                | 시그니처 도움말 (LSP)                                              | plugins/lsp.lua             |
| `<leader>gh`        | —                                                                  | plugins/lsp.lua             |
| `<leader>mt`        | Markdown render toggle                                             | plugins/render-markdown.lua |
| `<leader>tc`        | Toggle TS Context                                                  | plugins/treesitter.lua      |
| `[x`                | Jump to context (upward)                                           | plugins/treesitter.lua      |
| `<leader>sp`        | TS swap next param                                                 | plugins/treesitter.lua      |
| `<leader>sP`        | TS swap prev param                                                 | plugins/treesitter.lua      |
| `<leader>u`         | —                                                                  | plugins/undotree.lua        |

## Insert Mode

| 키          | 설명                     | 출처                |
| ----------- | ------------------------ | ------------------- |
| `<C-CR>`    | 제안 전체 수락 (Copilot) | plugins/copilot.lua |
| `<C-Right>` | 단어 단위 수락 (Copilot) | plugins/copilot.lua |
| `<C-l>`     | 줄 단위 수락 (Copilot)   | plugins/copilot.lua |
| `<C-j>`     | 다음 제안 (Copilot)      | plugins/copilot.lua |
| `<C-k>`     | 이전 제안 (Copilot)      | plugins/copilot.lua |
| `<C-e>`     | 제안 닫기 (Copilot)      | plugins/copilot.lua |

## Visual Mode

| 키           | 설명                                       | 출처                     |
| ------------ | ------------------------------------------ | ------------------------ |
| `<leader>as` | Send to Claude                             | plugins/claudecode.lua   |
| `gc`         | Toggles the region using linewise comment  | plugins/comment.lua      |
| `gb`         | Toggles the region using blockwise comment | plugins/comment.lua      |
| `<leader>cq` | 선택 코드에 질문 입력                      | plugins/copilot-chat.lua |

## Normal / Visual Mode

| 키           | 설명                         | 출처                     |
| ------------ | ---------------------------- | ------------------------ |
| `<leader>ci` | Format buffer (or selection) | plugins/conform.lua      |
| `<leader>ce` | 코드 설명                    | plugins/copilot-chat.lua |
| `<leader>cr` | 코드 리뷰                    | plugins/copilot-chat.lua |
| `<leader>cf` | 코드 수정                    | plugins/copilot-chat.lua |
| `<leader>ua` | Cursor agent 선택 코드 전송  | plugins/cursorcli.lua    |

## Normal / Visual / Operator Mode

| 키  | 설명             | 출처              |
| --- | ---------------- | ----------------- |
| `S` | Flash Treesitter | plugins/flash.lua |

