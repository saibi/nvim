#!/usr/bin/env python3
"""
nvim 설정 파일을 파싱해 KEYMAPS.md를 자동 생성

Usage:
    python3 gen_keymaps.py
    python3 gen_keymaps.py --nvim-dir /path/to/nvim
    python3 gen_keymaps.py --nvim-dir /path/to/nvim --output /path/to/KEYMAPS.md
"""

import re
import argparse
import unicodedata
from pathlib import Path
from datetime import date
from collections import defaultdict


MODE_LABEL = {
    "n": "Normal", "i": "Insert", "v": "Visual",
    "x": "Visual", "o": "Operator", "c": "Command",
    "t": "Terminal", "s": "Select",
}
MODE_ORDER = ["Normal", "Insert", "Visual", "Operator", "Command", "Terminal"]

FUNC_DESC = {
    "vim.lsp.buf.definition":     "정의로 이동 (LSP)",
    "vim.lsp.buf.references":     "참조 목록 (LSP)",
    "vim.lsp.buf.hover":          "호버 정보 (LSP)",
    "vim.lsp.buf.rename":         "이름 변경 (LSP)",
    "vim.lsp.buf.declaration":    "선언으로 이동 (LSP)",
    "vim.lsp.buf.implementation": "구현으로 이동 (LSP)",
    "vim.lsp.buf.signature_help": "시그니처 도움말 (LSP)",
    "vim.diagnostic.goto_next":   "다음 진단으로",
    "vim.diagnostic.goto_prev":   "이전 진단으로",
    "vim.cmd.Ex":                 "netrw 열기",
}

COPILOT_ACTION_DESC = {
    "accept":              "제안 전체 수락 (Copilot)",
    "accept_word":         "단어 단위 수락 (Copilot)",
    "accept_line":         "줄 단위 수락 (Copilot)",
    "next":                "다음 제안 (Copilot)",
    "prev":                "이전 제안 (Copilot)",
    "dismiss":             "제안 닫기 (Copilot)",
    "toggle_auto_trigger": "자동 트리거 토글 (Copilot)",
}


# ── 유틸 ───────────────────────────────────────────────────────

def strip_comments(text: str) -> str:
    lines = []
    for line in text.splitlines():
        if line.lstrip().startswith("--"):
            continue
        result, in_str, str_char = [], False, None
        i = 0
        while i < len(line):
            c = line[i]
            if in_str:
                result.append(c)
                if c == str_char and (i == 0 or line[i-1] != "\\"):
                    in_str = False
            else:
                if c in ('"', "'"):
                    in_str, str_char = True, c
                    result.append(c)
                elif c == "-" and i + 1 < len(line) and line[i+1] == "-":
                    break
                else:
                    result.append(c)
            i += 1
        lines.append("".join(result))
    return "\n".join(lines)


def fmt_mode(raw: str) -> str:
    tokens = re.findall(r'[a-z]', raw)
    seen, result = set(), []
    for t in tokens:
        name = MODE_LABEL.get(t, t)
        if name not in seen:
            seen.add(name)
            result.append(name)
    return " / ".join(result) if result else "Normal"


def find_closer(text: str, start: int, open_ch: str, close_ch: str) -> int:
    depth = 0
    for i in range(start, len(text)):
        if text[i] == open_ch:
            depth += 1
        elif text[i] == close_ch:
            depth -= 1
            if depth == 0:
                return i
    return -1


def str_width(s: str) -> int:
    """터미널 표시 너비 계산 (한글 등 전각 문자 = 2칸)"""
    return sum(
        2 if unicodedata.east_asian_width(c) in ("W", "F") else 1
        for c in s
    )


def ljust_wide(s: str, width: int) -> str:
    """전각 문자를 고려한 좌측 정렬 패딩"""
    return s + " " * max(0, width - str_width(s))


def make_table(headers: list[str], rows: list[list[str]]) -> list[str]:
    """컬럼 너비를 가장 긴 항목 기준으로 맞춘 마크다운 테이블 생성"""
    widths = [str_width(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], str_width(cell))

    def fmt_row(cells):
        padded = (ljust_wide(cell, widths[i]) for i, cell in enumerate(cells))
        return "| " + " | ".join(padded) + " |"

    sep = "| " + " | ".join("-" * w for w in widths) + " |"
    return [fmt_row(headers), sep] + [fmt_row(row) for row in rows]


# ── 파서 ───────────────────────────────────────────────────────

def parse_keymap_set(text: str, source: str) -> list:
    text = strip_comments(text)
    results = []
    pat = re.compile(r'(?:vim\.)?keymap\.set\s*\(')
    for m in pat.finditer(text):
        open_pos  = m.end() - 1
        close_pos = find_closer(text, open_pos, "(", ")")
        if close_pos == -1:
            continue
        inner = text[open_pos + 1: close_pos]

        mk = re.match(
            r'\s*["\']([^"\']+)["\']\s*,\s*'
            r'["\']([^"\']+)["\']\s*,\s*'
            r'([^\n,)]+)',
            inner,
        )
        if not mk:
            continue

        mode_raw = mk.group(1)
        key      = mk.group(2)
        target   = mk.group(3).strip()

        desc_m = re.search(r'desc\s*=\s*["\']([^"\']+)["\']', inner)
        desc   = desc_m.group(1) if desc_m else next(
            (v for k, v in FUNC_DESC.items() if k in target), "—"
        )

        results.append({
            "mode": fmt_mode(mode_raw), "key": key,
            "desc": desc, "source": source,
        })
    return results


def parse_lazy_keys(text: str, source: str) -> list:
    text = strip_comments(text)
    results = []

    keys_m = re.search(r'\bkeys\s*=\s*\{', text)
    if not keys_m:
        return results

    outer_start = keys_m.end() - 1
    outer_end   = find_closer(text, outer_start, "{", "}")
    if outer_end == -1:
        return results

    block = text[outer_start + 1: outer_end]
    i = 0
    while i < len(block):
        if block[i] == "{":
            entry_end = find_closer(block, i, "{", "}")
            if entry_end == -1:
                break
            entry = block[i + 1: entry_end]

            key_m = re.match(r'\s*["\']([^"\']+)["\']', entry)
            if key_m:
                key    = key_m.group(1)
                desc_m = re.search(r'desc\s*=\s*["\']([^"\']+)["\']', entry)
                mode_m = re.search(r'mode\s*=\s*\{([^}]+)\}', entry)
                mode_s = re.search(r'mode\s*=\s*["\']([^"\']+)["\']', entry)

                desc = desc_m.group(1) if desc_m else "—"
                if mode_m:
                    mode = fmt_mode(mode_m.group(1))
                elif mode_s:
                    mode = fmt_mode(mode_s.group(1))
                else:
                    mode = "Normal"

                results.append({
                    "mode": mode, "key": key,
                    "desc": desc, "source": source,
                })
            i = entry_end + 1
        else:
            i += 1
    return results


def parse_copilot_suggestion(text: str, source: str) -> list:
    text = strip_comments(text)
    results = []
    km_m = re.search(r'keymap\s*=\s*\{([^}]+)\}', text, re.DOTALL)
    if not km_m:
        return results
    block = km_m.group(1)
    for action, desc in COPILOT_ACTION_DESC.items():
        m = re.search(rf'{action}\s*=\s*["\']([^"\']+)["\']', block)
        if m:
            results.append({
                "mode": "Insert", "key": m.group(1),
                "desc": desc, "source": source,
            })
    return results


def parse_default_keymaps(text: str, source: str) -> list:
    """-- [DEFAULT KEYMAPS] 주석 블록에서 플러그인 기본 키맵 파싱"""
    MODE_MAP = {
        "NORMAL": "Normal", "INSERT": "Insert", "VISUAL": "Visual",
        "OPERATOR": "Operator", "COMMAND": "Command", "TERMINAL": "Terminal",
        "SELECT": "Select",
    }
    results = []
    in_section = False
    current_mode = "Normal"

    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("--"):
            continue

        content = stripped[2:].strip()

        if "[DEFAULT KEYMAPS]" in content:
            in_section = True
            continue

        if not in_section:
            continue

        # 모드 헤더: "NORMAL mode", "VISUAL mode" 등
        mode_m = re.match(r'^([A-Z]+)\s+mode', content)
        if mode_m and mode_m.group(1) in MODE_MAP:
            current_mode = MODE_MAP[mode_m.group(1)]
            continue

        # 키맵 엔트리: `key` - description
        key_m = re.match(r'^`([^`]+)`\s*[-–]\s*(.+)', content)
        if key_m:
            results.append({
                "mode": current_mode,
                "key": key_m.group(1),
                "desc": key_m.group(2).strip(),
                "source": source,
            })

    return results


# ── 중복 감지 ───────────────────────────────────────────────────

def get_individual_modes(mode_str: str) -> set:
    return {m.strip() for m in mode_str.split("/")}


def find_duplicates(all_entries: list) -> list:
    from collections import defaultdict
    key_entries = defaultdict(list)
    for e in all_entries:
        key_entries[e["key"]].append(e)

    duplicates = []
    for key, entries in key_entries.items():
        seen_pairs = set()
        for i in range(len(entries)):
            for j in range(i + 1, len(entries)):
                e1, e2 = entries[i], entries[j]
                if e1["source"] == e2["source"]:
                    continue
                if get_individual_modes(e1["mode"]) & get_individual_modes(e2["mode"]):
                    pair_key = (key, e1["source"], e2["source"])
                    if pair_key not in seen_pairs:
                        seen_pairs.add(pair_key)
                        duplicates.append({"key": key, "entry1": e1, "entry2": e2})
    return duplicates


# ── 마크다운 생성 ───────────────────────────────────────────────

def generate(nvim_dir: Path, output: Path):
    all_entries: list[dict] = []

    init_lua = nvim_dir / "init.lua"
    if init_lua.exists():
        all_entries += parse_keymap_set(init_lua.read_text(), "init.lua")

    plugins_dir = nvim_dir / "lua" / "plugins"
    if plugins_dir.exists():
        for lua_file in sorted(plugins_dir.glob("*.lua")):
            text   = lua_file.read_text()
            source = f"plugins/{lua_file.name}"
            all_entries += parse_default_keymaps(text, source)
            if "copilot" in lua_file.name and "chat" not in lua_file.name:
                all_entries += parse_copilot_suggestion(text, source)
            else:
                all_entries += parse_lazy_keys(text, source)
                all_entries += parse_keymap_set(text, source)

    by_mode: dict[str, list] = defaultdict(list)
    for e in all_entries:
        by_mode[e["mode"]].append(e)

    ordered_modes = [m for m in MODE_ORDER if m in by_mode]
    for m in by_mode:
        if m not in ordered_modes:
            ordered_modes.append(m)

    headers = ["키", "설명", "출처"]
    lines = [
        "# Neovim Keymaps",
        "",
        f"> 자동 생성: {date.today()}",
        f"> `python3 gen_keymaps.py --nvim-dir {nvim_dir}` 로 재생성",
        "",
    ]

    for mode in ordered_modes:
        entries = by_mode[mode]
        rows    = [[f"`{e['key']}`", e["desc"], e["source"]] for e in entries]
        lines  += [f"## {mode} Mode", ""] + make_table(headers, rows) + [""]

    duplicates = find_duplicates(all_entries)
    if duplicates:
        dup_headers = ["키", "출처 1", "출처 2"]
        dup_rows = [
            [
                f"`{d['key']}`",
                f"{d['entry1']['desc']} ({d['entry1']['source']}, {d['entry1']['mode']})",
                f"{d['entry2']['desc']} ({d['entry2']['source']}, {d['entry2']['mode']})",
            ]
            for d in duplicates
        ]
        lines += ["---", "", "## 중복 키맵 충돌", ""] + make_table(dup_headers, dup_rows) + [""]

    output.write_text("\n".join(lines) + "\n")
    print(f"✓ {output}")
    print(f"  총 {len(all_entries)}개 키맵  |  nvim-dir: {nvim_dir}")
    for mode in ordered_modes:
        print(f"  {mode}: {len(by_mode[mode])}개")
    if duplicates:
        print(f"  ⚠ 중복 키맵 {len(duplicates)}건")


# ── 진입점 ─────────────────────────────────────────────────────

def main():
    default_dir = Path.home() / ".config" / "nvim"

    parser = argparse.ArgumentParser(
        description="nvim 설정 파일 → KEYMAPS.md 자동 생성"
    )
    parser.add_argument(
        "--nvim-dir",
        type=Path,
        default=default_dir,
        metavar="DIR",
        help=f"nvim 설정 디렉토리 (기본값: {default_dir})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        metavar="FILE",
        help="출력 파일 경로 (기본값: <nvim-dir>/KEYMAPS.md)",
    )
    args = parser.parse_args()

    nvim_dir = args.nvim_dir.expanduser().resolve()
    output   = (args.output or nvim_dir / "KEYMAPS.md").expanduser().resolve()

    if not nvim_dir.exists():
        print(f"오류: 디렉토리가 없습니다 → {nvim_dir}")
        raise SystemExit(1)

    generate(nvim_dir, output)


if __name__ == "__main__":
    main()
