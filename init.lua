-- Leader 키를 Space로 설정
-- 주의: 다른 매핑보다 먼저 설정해야 합니다.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 미사용 provider 비활성화 (checkhealth 경고 억제)
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0

local opts = vim.opt

-- E W 표시 안되도록 하려면 false 로 세팅해야함 
vim.diagnostic.config({
  signs = true,
})

-- 터미널의 컬러대로 nvim 사용 
opts.termguicolors = false

-- 줄 번호
opts.nu = true
opts.relativenumber = true

-- 들여쓰기
opts.tabstop = 4
opts.softtabstop = 4
opts.shiftwidth = 4
opts.expandtab = true
opts.smartindent = true

-- 일반 설정
opts.wrap = false
opts.swapfile = false
opts.backup = false
opts.cursorline = true

-- 검색
opts.hlsearch = true
opts.incsearch = true

-- .nvim.lua 인식 
opts.exrc = true

-- colorscheme
vim.cmd.colorscheme("lunaperche")

require ("config.lazy")

-- OSC 52: SSH + tmux 환경에서 로컬 클립보드로 복사
vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
}


--
-- 첫줄/중간/마지막줄 라인 번호 표시
-- 
local ns_id = vim.api.nvim_create_namespace("ScreenBoundaryNumbers")

local function update_screen_boundary_numbers()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    local success, win_info = pcall(function() return vim.fn.getwininfo(winid)[1] end)
    if not success or not win_info then return end

    local top_line = win_info.topline
    local bot_line = win_info.botline
    local mid_line = math.floor((top_line + bot_line) / 2)
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- 스타일 설정
    local opts = {
        virt_text_pos = 'right_align', -- 화면 오른쪽 끝으로 정렬
        hl_group = 'NonText',
    }

    -- 1. 화면 최상단
    opts.virt_text = {{ "󰜮 Top: " .. top_line, "DiagnosticInfo" }}
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, top_line - 1, 0, opts)

    -- 2. 화면 중간
    -- if mid_line ~= top_line and mid_line ~= bot_line then
    --     opts.virt_text = {{ "󰜬 Mid: " .. mid_line, "DiagnosticHint" }}
    --     vim.api.nvim_buf_set_extmark(bufnr, ns_id, mid_line - 1, 0, opts)
    -- end

    -- 3. 화면 최하단
    local display_bot = math.min(bot_line, line_count)
    opts.virt_text = {{ "󰜯 Bot: " .. display_bot, "DiagnosticWarn" }}
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, display_bot - 1, 0, opts)
end

vim.api.nvim_create_autocmd({ "WinScrolled", "CursorMoved", "BufEnter", "WinResized" }, {
    callback = update_screen_boundary_numbers,
})




-- keymaps
local keymap = vim.keymap

keymap.set("n", "-", vim.cmd.Ex)

-- nvim-telescope
local builtin = require('telescope.builtin')
keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Telescope LSP document symbols' })
keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Telescope LSP workspace symbols' })
keymap.set('n', '<leader>ft', builtin.current_buffer_tags, { desc = 'Telescope current buffer tags' })
keymap.set('n', '<leader>fT', builtin.tags, { desc = 'Telescope project tags' })

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")


-- 다음 에러/경고로 이동 (Next)
keymap.set('n', 'g>', vim.diagnostic.goto_next)

-- 이전 에러/경고로 이동 (Prev)
keymap.set('n', 'g<', vim.diagnostic.goto_prev)

-- 경고 float 창 열기
keymap.set('n', '<leader>gd', vim.diagnostic.open_float)

-- 현재 파일 확장자를 보고 반대 파일로 점프
vim.keymap.set('n', 'gs', function()
  local file_path = vim.fn.expand('%:p:r') -- 확장자 제외한 전체 경로
  local ext = vim.fn.expand('%:e')         -- 현재 확장자

  if ext == 'h' or ext == 'hpp' then
    -- 헤더 -> 소스 이동
    if vim.fn.filereadable(file_path .. '.c') == 1 then
      vim.cmd('edit ' .. file_path .. '.c')
    elseif vim.fn.filereadable(file_path .. '.cpp') == 1 then
      vim.cmd('edit ' .. file_path .. '.cpp')
    elseif vim.fn.filereadable(file_path .. '.cc') == 1 then
      vim.cmd('edit ' .. file_path .. '.cc')
    else
      print("대응하는 소스 파일(.c/.cpp)을 찾을 수 없습니다.")
    end
  elseif ext == 'c' or ext == 'cpp' or ext == 'cc' then
    -- 소스 -> 헤더 이동
    if vim.fn.filereadable(file_path .. '.h') == 1 then
      vim.cmd('edit ' .. file_path .. '.h')
    elseif vim.fn.filereadable(file_path .. '.hpp') == 1 then
      vim.cmd('edit ' .. file_path .. '.hpp')
    else
      print("대응하는 헤더 파일(.h/.hpp)을 찾을 수 없습니다.")
    end
  end
end,
{ desc = '파일 확장자 반대 파일 점프' }
)


-- treesitter 에서 c, cpp 자동 indent 가 잘 안됨. 끄기 
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.indentexpr = ""
  end,
})

-- keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- VS Code 스타일 줄 이동
-- keymap.set("v", "J", ":m '>=1<CR>gv=gv")
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 삶을 편하게 하는 키바인딩
-- keymap.set("i", "jj", "<Esc>")
-- keymap.set("n", "Y", "yg$")
-- keymap.set("n", "J", "mzJ`z")
-- keymap.set("n", "<C-d>", "<C-d>zz")
-- keymap.set("n", "<C-u>", "<C-u>zz")
-- keymap.set("n", "n", "nzzzv")
-- keymap.set("n", "N", "Nzzzv")

-- 여러 유틸리티용 복사/붙여넣기 키바인딩
-- keymap.set("x", "<leader>p", "\"_dP")
-- keymap.set("n", "<leader>y", "\"+y")
-- keymap.set("v", "<leader>y", "\"+y")
-- keymap.set("n", "<leader>Y", "\"+Y")
-- keymap.set("n", "<leader>d", "\"_d")
-- keymap.set("v", "<leader>d", "\"_d")

-- 더 삶의 질을 올려주는 키바인딩
-- keymap.set("n", "Q", "<nop>")
-- keymap.set("n", "<leader>f", function ()
--     vim.lsp.buf.format({ async = true })
-- end)
-- keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- 오류 탐색
-- keymap.set("n", "<C-k>", "<cmd>cprev<CR>", { silent = true })
-- keymap.set("n", "<C-j>", "<cmd>cnext<CR>", { silent = true })

-- 버퍼 탐색
-- keymap.set("n", "<leader>bx", "<cmd>bdelete<CR>", { silent = true })
-- keymap.set("n", "<leader>bb", "<cmd>bnext<CR>", { silent = true })
-- keymap.set("n", "<leader>bB", "<cmd>bprev<CR>", { silent = true })
