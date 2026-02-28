-- ~/.config/nvim/lua/plugins/treesitter.lua
--
-- ✅ nvim-treesitter main 브랜치 + Neovim 0.11+ 전용

-- ──────────────────────────────────────────────────────────────────
-- 📋 단축키 요약
-- ──────────────────────────────────────────────────────────────────
--
-- [Textobjects Select]  x/o 모드:
--   af/if  : 함수 전체/본문    ac/ic : 클래스 전체/본문
--   aa/ia  : 파라미터          ai/ii : if 블록
--   al/il  : 루프              ab/ib : 블록
--
-- [Move]  n/x/o 모드:
--   ]f/[f  : 다음/이전 함수 시작   ]F/[F : 다음/이전 함수 끝
--   ]c/[c  : 다음/이전 클래스      ]a/[a : 다음/이전 파라미터
--   ]i/[i  : 다음/이전 if 블록     ]l/[l : 다음/이전 루프
--
-- [Swap]
--   <leader>sp : 다음 파라미터와 교환
--   <leader>sP : 이전 파라미터와 교환
--
-- [Repeat]
--   ; / ,  : 마지막 TS move 반복 (f/F/t/T 포함)
--
-- [Fold]  (Vim 기본 키)
--   za : 토글   zc : 닫기   zo : 열기   zM : 전체닫기   zR : 전체열기
--
-- [Context]
--   <leader>tc : 컨텍스트 표시 토글
--   [x         : 현재 함수/클래스 선언부로 점프
-- ──────────────────────────────────────────────────────────────────

return {

  -- ──────────────────────────────────────────────────────────────
  -- ① 코어: 파서 설치 + highlight / indent / fold 활성화
  -- ──────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy   = false,    -- ⚠️ 공식 문서: lazy-loading 미지원, 반드시 false
    build  = ":TSUpdate",

    config = function()
      local ts = require("nvim-treesitter")

      -- ── 파서 목록 ────────────────────────────────────────────
      -- 신버전은 ensure_installed 옵션이 없음 → install() 직접 호출
      local parsers = {
        "c", "cpp", "cmake", "make",
        "rust",
        "python", "bash", "lua",
        "javascript", "typescript", "tsx", "html", "css",
        "json", "jsonc", "yaml", "toml",
        "markdown", "markdown_inline",
        "vim", "vimdoc", "query",
        "dockerfile", "gitignore",
      }

      ts.setup()  -- install_dir 등 기본값 적용 (커스터마이징 필요 없으면 그대로 유지)

      -- 비동기 설치: defer_fn으로 시작 블로킹 방지
      -- 이미 설치된 파서는 no-op 이므로 매번 실행해도 무방
      vim.defer_fn(function()
        ts.install(parsers):wait(300000)  -- 최대 5분 대기
      end, 0)

      -- ── Highlight ────────────────────────────────────────────
      -- 신버전: highlight = { enable = true } 옵션 제거됨
      -- → FileType autocmd 안에서 vim.treesitter.start() 직접 호출
      -- pattern = "*" 로 모든 파일 대응, get_lang() 이 filetype → 파서명 매핑 처리
      -- (예: "typescriptreact" → "tsx" 파서 자동 인식)
      vim.api.nvim_create_autocmd("FileType", {
        group   = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
        pattern = "*",
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if lang then
            pcall(vim.treesitter.start, ev.buf)  -- 파서 없을 때 오류 방지
          end
        end,
      })

      -- ── Indent ───────────────────────────────────────────────
      -- 신버전 공식 방식: vim.bo.indentexpr 직접 설정
      -- yaml 은 불안정하므로 제외
      vim.api.nvim_create_autocmd("FileType", {
        group   = vim.api.nvim_create_augroup("ts_indent", { clear = true }),
        pattern = {
          "c", "cpp", "rust", "make",
          "python", "bash", "lua",
          "javascript", "typescript",
          "html", "css",
          "json", "jsonc", "toml",
          "markdown",
        },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- ── Fold ─────────────────────────────────────────────────
      -- 신버전 공식 방식: vim.wo[0][0] 형태 (window-local 옵션)
      -- 구버전 vim.opt.foldexpr = "..." 방식은 0.11 에서 동작 불안정
      vim.api.nvim_create_autocmd("FileType", {
        group   = vim.api.nvim_create_augroup("ts_fold", { clear = true }),
        pattern = "*",
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if lang then
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldlevel  = 99   -- 시작 시 모두 펼침 (0이면 모두 접힘)
          end
        end,
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────────
  -- ② Incremental Selection
  -- ──────────────────────────────────────────────────────────────
  -- ⚠️ main 브랜치에서 incremental_selection 모듈이 공식 제거됨
  --    → MeanderingProgrammer/treesitter-modules.nvim 으로 동일 기능 복원
  --
  --  <M-v>   : Normal → Visual 진입 + 첫 노드 선택   (Option+v)
  --  <M-v>   : Visual 에서 부모 노드로 범위 확장
  --  <M-s>   : 스코프(함수/블록/클래스) 단위로 확장  (Option+s)
  --  <M-V>   : 자식 노드로 범위 축소                 (Option+Shift+v)
  --
  -- ※ macOS 터미널에서 <M-?> 사용 시 Option 키 설정 필요:
  --   iTerm2  → Profiles > Keys > Left Option Key → Esc+
  --   Kitty   → kitty.conf: macos_option_as_alt yes
  --   Alacritty → option_as_alt = "Both"
  -- ──────────────────────────────────────────────────────────────
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "<M-v>",   -- Option+v        : 선택 시작
          node_incremental  = "<M-v>",   -- Option+v        : 부모 노드로 확장
          scope_incremental = "<M-s>",   -- Option+s        : 스코프 단위 확장
          node_decremental  = "<M-V>",   -- Option+Shift+v  : 자식 노드로 축소
        },
      },
    },
  },

  -- ──────────────────────────────────────────────────────────────
  -- ③ Textobjects
  -- ──────────────────────────────────────────────────────────────
  -- ⚠️ main 브랜치 변경점:
  --   ❌ configs.setup({ textobjects = { select = { keymaps = { ["af"] = ... } } } })
  --   ✅ require("nvim-treesitter-textobjects").setup({...})
  --      + vim.keymap.set() 으로 모듈 함수 직접 호출
  --
  -- [Select]  x/o 모드에서:
  --   af/if  : 함수 전체/본문만       vaf → 함수 전체 선택, dif → 본문 삭제
  --   ac/ic  : 클래스 전체/본문만     yac → 클래스 복사
  --   aa/ia  : 파라미터+콤마 / 값만   cia → 파라미터 교체
  --   ai/ii  : if 블록 전체/본문
  --   al/il  : 루프 전체/본문
  --   ab/ib  : { } 블록 전체/본문
  --
  -- [Move]  n/x/o 모드에서:
  --   ]f/[f  : 다음/이전 함수 시작    ]F/[F : 다음/이전 함수 끝
  --   ]c/[c  : 다음/이전 클래스       ]a/[a : 다음/이전 파라미터
  --   ]i/[i  : 다음/이전 if 블록      ]l/[l : 다음/이전 루프
  --
  -- [Swap]
  --   <leader>sp : 다음 파라미터와 교환    fn(a,b) → fn(b,a)
  --   <leader>sP : 이전 파라미터와 교환
  --
  -- [Repeat Move]
  --   ; / ,  : 마지막 TS move 반복 (f/F/t/T 도 포함)
  -- ──────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch       = "main",
    dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
    event        = { "BufReadPre", "BufNewFile" },

    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
          selection_modes = {
            ["@function.outer"]  = "V",
            ["@class.outer"]     = "V",
            ["@parameter.outer"] = "v",
          },
        },
        move = { set_jumps = true },
      })

      -- ── Select 키맵 ─────────────────────────────────────────
      local sel = require("nvim-treesitter-textobjects.select").select_textobject
      local select_maps = {
        { "af", "@function.outer"    },
        { "if", "@function.inner"    },
        { "ac", "@class.outer"       },
        { "ic", "@class.inner"       },
        { "aa", "@parameter.outer"   },
        { "ia", "@parameter.inner"   },
        { "ai", "@conditional.outer" },
        { "ii", "@conditional.inner" },
        { "al", "@loop.outer"        },
        { "il", "@loop.inner"        },
        { "ab", "@block.outer"       },
        { "ib", "@block.inner"       },
      }
      for _, m in ipairs(select_maps) do
        vim.keymap.set({ "x", "o" }, m[1], function()
          sel(m[2], "textobjects")
        end, { desc = "TS select " .. m[2] })
      end

      -- ── Move 키맵 ────────────────────────────────────────────
      local move = require("nvim-treesitter-textobjects.move")
      local move_maps = {
        { "]f", "goto_next_start",     "@function.outer"    },
        { "]F", "goto_next_end",       "@function.outer"    },
        { "]c", "goto_next_start",     "@class.outer"       },
        { "]C", "goto_next_end",       "@class.outer"       },
        { "]a", "goto_next_start",     "@parameter.inner"   },
        { "]i", "goto_next_start",     "@conditional.outer" },
        { "]l", "goto_next_start",     "@loop.outer"        },
        { "[f", "goto_previous_start", "@function.outer"    },
        { "[F", "goto_previous_end",   "@function.outer"    },
        { "[c", "goto_previous_start", "@class.outer"       },
        { "[C", "goto_previous_end",   "@class.outer"       },
        { "[a", "goto_previous_start", "@parameter.inner"   },
        { "[i", "goto_previous_start", "@conditional.outer" },
        { "[l", "goto_previous_start", "@loop.outer"        },
      }
      for _, m in ipairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          move[m[2]](m[3], "textobjects")
        end, { desc = "TS " .. m[2] .. " " .. m[3] })
      end

      -- ── Swap 키맵 ────────────────────────────────────────────
      local swap = require("nvim-treesitter-textobjects.swap")
      vim.keymap.set("n", "<leader>sp", function()
        swap.swap_next("@parameter.inner", "textobjects")
      end, { desc = "TS swap next param" })
      vim.keymap.set("n", "<leader>sP", function()
        swap.swap_previous("@parameter.inner", "textobjects")
      end, { desc = "TS swap prev param" })

      -- ── Repeatable Move ──────────────────────────────────────
      -- ; / , 로 마지막 TS move 반복 + 기본 f/F/t/T 도 ;/, 로 반복
      local rep = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", rep.repeat_last_move_next,     { desc = "Repeat TS move →" })
      vim.keymap.set({ "n", "x", "o" }, ",", rep.repeat_last_move_previous, { desc = "Repeat TS move ←" })
      vim.keymap.set({ "n", "x", "o" }, "f", rep.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", rep.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", rep.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", rep.builtin_T_expr, { expr = true })
    end,
  },

  -- ──────────────────────────────────────────────────────────────
  -- ④ Context: 현재 함수/클래스를 화면 상단에 고정 표시
  -- ──────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      enable     = true,
      max_lines  = 3,
      trim_scope = "outer",
    },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<cr>",
        desc = "Toggle TS Context" },
      { "[x", function() require("treesitter-context").go_to_context() end,
        desc = "Jump to context (upward)" },
    },
  },

  -- ──────────────────────────────────────────────────────────────
  -- ⑤ Rainbow Delimiters: 중첩 괄호 깊이별 색상 구분
  -- ──────────────────────────────────────────────────────────────
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
    event = { "BufReadPre", "BufNewFile" },
    -- 설치만 해도 자동 활성화됨
  },

}

