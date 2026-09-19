# Reference

Information-oriented. Facts, no narrative. Reflects the config as it actually is.

## File layout

| Path | Contents |
|---|---|
| `~/.zshenv` | `ZDOTDIR`, `SHELL_SESSIONS_DISABLE`, `XDG_CACHE_HOME`, `LESSHISTFILE` — exports only, read by every zsh invocation |
| `~/.config/zsh/.zprofile` | Homebrew `eval "$(brew shellenv zsh)"` — login shells only |
| `~/.config/zsh/.zshrc` | options, history, completion, keybindings, aliases, tool init, plugins |
| `~/.config/zsh/prompt.zsh` | the prompt — conditionally sourced, no dependency on `colors.zsh` |
| `~/.config/zsh/colors.zsh` | color palette for every *other* tool — conditionally sourced, optional |
| `~/.config/zsh/.zcompdump`, `.zsh_history`, `lesshst` | generated state — relocated here by `ZDOTDIR`/`LESSHISTFILE` |
| `~/.config/cache/` | `XDG_CACHE_HOME`; untracked |
| `~/.config/ghostty/config` | `font-size = 16` |
| `~/Library/Application Support/VSCodium/User/settings.json` | editor/terminal font + size |

## `.zshrc` section order

Only two orderings are load-bearing: `compinit` must run before the completion
`zstyle`s, and `zsh-syntax-highlighting` must be the last thing sourced in the
file — it wraps every widget defined above it. Everything else is grouped for
reading.

1. palette (`colors.zsh`) · 2. shell options · 3. history · 4. completion ·
5. key bindings · 6. prompt (`prompt.zsh`) · 7. aliases · 8. tools (fzf, zoxide) ·
9. plugins

## Prompt

Defined entirely in `prompt.zsh`. Two hooks (`preexec`, `precmd`), no daemon,
no `vcs_info`, no git call.

```
~/Developer/TeXCat ❯               3.0s  ✓   10:27 PM
```

| Segment | Side | Shown when | Color |
|---|---|---|---|
| parent path | left | always | `dir` blue `#afcbff` |
| current folder | left | always | `link` cyan `#6ad9ee`, bold |
| `❯` | left | always | `exe` green, or `alert` red after a failure |
| elapsed time | right | last command took more than `PROMPT_MIN_DURATION` | `quiet` grey |
| `✓` | right | exit code 0 | `exe` green |
| `✘ <code>` | right | exit code non-zero | `alert` red |
| clock (12-hour) | right | always | `quiet` grey |

| Variable | Default | Does |
|---|---|---|
| `PROMPT_MIN_DURATION` | `0.2` | floor, in seconds, below which the duration segment is hidden |
| `PROMPT_POWERLINE` | `1`, or `0` under Apple Terminal | Nerd Font glyphs (hourglass, clock) vs none |

Notes:

- Path truncation is `%(5~|%-1~/…/%3~|%~)` — full path up to 4 components, then
  first component, `…`, last 3.
- `✓` (U+2713) and `✘` (U+2718) are ordinary Unicode, not Nerd Font glyphs, so
  they render everywhere and sit outside the `PROMPT_POWERLINE` branch.
- Icons are stored as literal characters, not `$'\uXXXX'` escapes — the escapes
  raise `character not in range` wherever the locale isn't UTF-8.
- Segments are joined with `${(j: :)…}`, so a hidden segment leaves no gap.
- The duration is suppressed only on the first prompt of a session and after a
  bare Enter, where no command ran to time.
- Colors are defined in `prompt.zsh` itself, with a truecolor branch and an
  xterm-256 fallback. It renders correctly under `zsh -f`.

Measured: under 10 ms per prompt, ~40 ms interactive startup (`compinit` is
most of it).

## `colors.zsh`

One `PAL` table of hex values, compiled once at startup into `SGR` (24-bit when
`$COLORTERM` advertises it, quantised to the xterm-256 cube otherwise) and
mirrored into `ZC` for prompt-escape spellings. Two rules: **lightness carries
hierarchy** (five neutral tiers: `ink` → `ink2` → `muted` → `quiet` → `rule`),
**hue carries category**.

Consumers: `EZA_COLORS`, `LS_COLORS` (which also feeds the completion menu via
`zstyle ':completion:*' list-colors`), `FZF_DEFAULT_OPTS`,
`ZSH_HIGHLIGHT_STYLES`, `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE`, `BAT_THEME`.

### eza filename colors

The two-letter `EZA_COLORS` codes cover eza's own columns (permission bits,
size scale, git status, ownership). Filenames themselves are colored by an
extension map:

| Category | Hue | Extensions |
|---|---|---|
| source | `exe` green | `py rs go c h cpp swift lua rb java zsh sh bash fish vim el` |
| web/markup | `link` cyan | `ts tsx js jsx html css scss svelte vue sql` |
| config | `g_mod` amber | `json yaml yml toml ini conf cfg plist`, `*rc`, `Makefile`, `Dockerfile`, `justfile` |
| prose | `special` lavender | `md rst org tex pdf` |
| plain text | `muted` grey | `txt`, `LICENSE` |
| archives | `archive` orange | `zip tar gz tgz bz2 xz zst 7z rar dmg pkg` |
| secrets | `alert` red | `pem key p12 env`, `.env` |
| generated | `quiet`/`rule` grey | `lock sum min.js map log pyc o bak` |

`README`/`README.md` are bold `ink`. Prose is deliberately *not* `dir` blue —
that made a `.md` the same hue as the folder beside it, with only bold telling
them apart.

`*rc=` matches `.zshrc` and `.npmrc`, but also anything else ending in "rc".

## `setopt` in use

| Option | Default | Does |
|---|---|---|
| `AUTO_CD` | off | bare dir name + Enter → cd |
| `EXTENDED_GLOB` | off | `^`/`~` negation in globs |
| `GLOB_DOTS` | off | `*` matches dotfiles too |
| `RM_STAR_WAIT` | off | confirm before `rm *` |
| `NO_CASE_GLOB` | off | case-insensitive globs |
| `INTERACTIVE_COMMENTS` | off | `#` comments at the prompt |
| `HIST_IGNORE_DUPS` | off | skip adjacent duplicate history entries |
| `HIST_IGNORE_ALL_DUPS` | off | skip duplicates anywhere, not just adjacent |
| `HIST_SAVE_NO_DUPS` | off | same, applied on disk write |
| `HIST_FIND_NO_DUPS` | off | skip duplicates while browsing, don't delete them |
| `HIST_EXPIRE_DUPS_FIRST` | off | drop duplicates before unique entries when trimming |
| `HIST_IGNORE_SPACE` | off | leading-space commands aren't recorded |
| `HIST_REDUCE_BLANKS` | off | strip extra whitespace before saving |
| `SHARE_HISTORY` | off | live cross-tab history sync |

## Key bindings

| Key | Widget | Note |
|---|---|---|
| `Ctrl-U` | `backward-kill-line` | default is `kill-whole-line` |
| `Up` / `Down` (`^[[A`/`^[[B`) | `history-beginning-search-*-end` | matches full typed prefix, not just first word |
| `Ctrl-T` (fzf) | `fzf-file-widget` | fuzzy file find, `bat` preview |
| `Ctrl-R` (fzf) | `fzf-history-widget` | fuzzy history search |
| `Alt-C` | unbound | explicitly removed (`bindkey -r '\ec'`) |

`WORDCHARS='*?_-.[]~&;!#$%^(){}<>'` — `/` and `=` removed from the default so
word motion stops at path components.

## Aliases

| Alias | Expands to |
|---|---|
| `ls` | `eza --color=always --icons=$_eza_icons -1` |
| `ll` | `eza -l --git --color-scale=size --color-scale-mode=fixed --no-user` |
| `la` | same as `ll`, plus `-a` |
| `lt` | `eza --tree --level=2 --git-ignore` |
| `lta` | `eza --tree --git-ignore` (unlimited depth) |
| `cat` | `bat --paging=never --style=plain` |
| `grep` | `grep --color=auto` |
| `zr` | `exec zsh` |
| `c` | `clear` |
| `zl` | `zoxide query -ls` |
| `z` / `zi` | from `zoxide init zsh` |

`$_eza_icons` is `never` under Apple Terminal and `always` elsewhere, resolved
once at startup and unset afterwards.

## Tools installed (Homebrew)

`eza`, `bat`, `fzf`, `zoxide`, `fd`, `ripgrep`, `zsh-autosuggestions`,
`zsh-syntax-highlighting`

Powerlevel10k is no longer installed or referenced.

## Fonts installed (Nerd Font, `Mono` variant in use)

| Font | Used for |
|---|---|
| `AnnotationM NF` | VSCodium terminal |
| `Victor Mono` | VSCodium editor |
| Ghostty | bundled Nerd Font Symbols internally, no install needed |

## `$TERM_PROGRAM` values (verified, not assumed)

| Terminal | Value |
|---|---|
| VSCodium | `vscode` |
| Apple Terminal.app | `Apple_Terminal` |
| Ghostty | `ghostty` (confirmed from Ghostty's own source) |

Two places branch on it: the `eza --icons` aliases and the prompt's glyph
fallback.
