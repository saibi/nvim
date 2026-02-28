-- Leader 키를 Space로 설정
-- 주의: 다른 매핑보다 먼저 설정해야 합니다.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = vim.opt

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


require ("config.lazy")
require ("keymaps")

