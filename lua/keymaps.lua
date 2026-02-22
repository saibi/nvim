local keymap = vim.keymap

keymap.set("n", "-", vim.cmd.Ex)

-- keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- VS Code 스타일 줄 이동
keymap.set("v", "J", ":m '>=1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 삶을 편하게 하는 키바인딩
keymap.set("i", "jj", "<Esc>")
keymap.set("n", "Y", "yg$")
keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- 여러 유틸리티용 복사/붙여넣기 키바인딩
keymap.set("x", "<leader>p", "\"_dP")
keymap.set("n", "<leader>y", "\"+y")
keymap.set("v", "<leader>y", "\"+y")
keymap.set("n", "<leader>Y", "\"+Y")
keymap.set("n", "<leader>d", "\"_d")
keymap.set("v", "<leader>d", "\"_d")

-- 더 삶의 질을 올려주는 키바인딩
keymap.set("n", "Q", "<nop>")
keymap.set("n", "<leader>f", function ()
    vim.lsp.buf.format({ async = true })
end)
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- 오류 탐색
keymap.set("n", "<C-k>", "<cmd>cprev<CR>", { silent = true })
keymap.set("n", "<C-j>", "<cmd>cnext<CR>", { silent = true })

-- 버퍼 탐색
keymap.set("n", "<leader>bx", "<cmd>bdelete<CR>", { silent = true })
keymap.set("n", "<leader>bb", "<cmd>bnext<CR>", { silent = true })
keymap.set("n", "<leader>bB", "<cmd>bprev<CR>", { silent = true })



-- nvim-telescope
local builtin = require('telescope.builtin')
keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
