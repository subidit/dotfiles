# Dotfile decisions

A running log of what's in the zsh config and why — not a full changelog, just the reasoning, so future-me doesn't have to re-derive it.

## Layout

- **`~/.zshenv`** holds only `ZDOTDIR` and `SHELL_SESSIONS_DISABLE`. This is the one file that can't move — zsh always checks `$HOME/.zshenv` before it even knows where `$ZDOTDIR` is, so it's the unavoidable bootstrap.
- Everything else lives in **`~/.config/zsh/`** (`.zprofile`, `.zshrc`). Once `ZDOTDIR` is set, `compinit`'s dumpfile and macOS's own `HISTFILE` default both resolve there automatically (`${ZDOTDIR:-$HOME}/...`) — no extra path config needed for `.zcompdump` or `.zsh_history`.
- **`.zprofile`** only has the Homebrew `eval "$(brew shellenv zsh)"` line — verified against Homebrew's actual `install.sh`, which itself targets `${ZDOTDIR:-$HOME}/.zprofile`. Kept out of `.zshenv` deliberately: it costs a subprocess spawn (~10ms) and `.zshenv` runs on *every* zsh invocation including nested ones, while `.zprofile` only runs once per login shell.
- Skipped full XDG (`XDG_CONFIG_HOME`/`XDG_CACHE_HOME`/etc). The `ZDOTDIR` move alone gets `$HOME` clean; the rest of XDG's value is cross-desktop-environment compatibility, which doesn't apply on macOS anyway.
- `.zsh_sessions/` (Terminal.app's own per-window bookkeeping, unrelated to zsh) can't be relocated, only disabled — `SHELL_SESSIONS_DISABLE=1`.

## Completion

- `typeset -U fpath` — Homebrew's own zsh build lists `site-functions` in `$fpath` more than once (confirmed even with zero config loaded); this dedupes it.
- `zmodload zsh/complist` — **caught a real bug**: `menu select` looked like it was working but the `menuselect` keymap didn't actually exist without this module loaded. Also a hard prerequisite for any future `bindkey -M menuselect` bindings.
- `zstyle menu select` / `matcher-list` (case-insensitive + partial completion match) / `group-name ''` (separate completion candidates by type) / `use-cache on` (speeds up expensive completions like `_git` branch lists) — all kept.
- Skipped `special-dirs` (adds `.`/`..` to TAB menus) — navigating by typing is faster than TAB-hunting for it.

## Shell options

Added: `AUTO_CD`, `EXTENDED_GLOB`, `GLOB_DOTS`, `RM_STAR_WAIT` (paired with `GLOB_DOTS` — dotfiles now match `rm *` too, so the confirmation pause matters), `NO_CASE_GLOB`, `INTERACTIVE_COMMENTS`.

Declined: `CORRECT` and `NO_BEEP` (tested, not wanted). `AUTO_PARAM_SLASH` — already on by default, adding it would be a no-op. The whole `pushd`/directory-stack cluster (`AUTO_PUSHD` etc.) — skipped because `zoxide` covers "jump back to a directory" better (persistent across sessions, frecency-ranked) than a session-only stack; the one thing native `cd -` does that zoxide doesn't already works with zero config.

## History

Added: `HIST_IGNORE_DUPS`, `HIST_IGNORE_ALL_DUPS`, `HIST_SAVE_NO_DUPS`, `HIST_FIND_NO_DUPS`, `HIST_EXPIRE_DUPS_FIRST`, `HIST_IGNORE_SPACE`, `HIST_REDUCE_BLANKS`, `SHARE_HISTORY` (live cross-tab sync — the main one actually asked for).

Left `HISTSIZE`/`SAVEHIST` at macOS's defaults (2000/1000) — plenty for casual use. Skipped `EXTENDED_HISTORY` (timestamps) since `SHARE_HISTORY` already forces that file format as a side effect — confirmed in the manual, not a guess. Skipped `HIST_VERIFY` — not using `!!`-style history expansion.

Side effect worth remembering: the raw `.zsh_history` file now has `: <timestamp>:<duration>;command` lines because of `SHARE_HISTORY`, not because `EXTENDED_HISTORY` was secretly on.

## Key bindings

- `WORDCHARS` — default includes `/` and `=`, so Alt-word-motion jumped whole paths in one leap. Removed both.
- `Ctrl-U` → `backward-kill-line` — default is `kill-whole-line`, which deletes text *after* the cursor too. Confirmed the difference is real (not a testing artifact) before changing it.
- `history-search-end` on Up/Down — matches the *whole* typed prefix, not just the first word (macOS's default `up-line-or-search` only matches word one). Took two rounds to get the actual key sequence right: first guess (`^[[A`) was wrong for no reason found, then a "fix" using `$key[Up]` (terminfo lookup) was *also* wrong because `$key[Up]` turned out empty in the real terminal. Ground truth came from `cat -v` showing the terminal's actual raw bytes (`^[[A`, it turns out the first guess was right all along). Lesson: terminfo/`$key[]` isn't reliable on this machine — hardcode the `cat -v`-verified sequence instead.
- Removed `Ctrl-P`/`Ctrl-N` bindings — not used, left at their untouched defaults.
- Skipped entirely, because they already worked without any config: Home/End/Delete (macOS's `/etc/zshrc` binds these via terminfo), Alt-Left/Right (terminal sends classic `^[b`/`^[f`, already bound by zsh's default emacs keymap), Alt-Backspace (already default). Ctrl-Left/Right skipped for a different reason — macOS's Mission Control claims that combo system-wide before it ever reaches the terminal.
- Skipped `menuselect` hjkl bindings — arrow keys and Enter already navigate the completion menu by default once `complist` is loaded; hjkl would be a redundant vim-style alternative for someone who doesn't use vim keys.
- `edit-command-line` (`Ctrl-X Ctrl-E`) and the `ze` alias (open `.zshrc` in `$EDITOR`) — both held off. `$EDITOR`/`$VISUAL` are still unset, so either would currently just try to execute the file path as a command.

## Aliases

- `ls`/`ll`/`la`/`lt`/`lta` via `eza`, `--icons=always` on all of them — briefly per-terminal-conditional (Ghostty bundles a Nerd Font internally; VSCodium/Apple Terminal didn't), removed once real Nerd Fonts (`AnnotationM NFM`, `GoogleSansCode NFM`, Victor Mono, Iosevka Term NF) were installed and set as the actual terminal fonts in all three apps — now unconditional. Dropped `--group-directories-first`, `--smart-group`, `--time-style=long-iso` from `ll`/`la` — simplicity preference. Added `--no-user` (hide owner column, not needed). Tried `--total-size` on `ll` for folder sizes, reverted — noticeably slow on real directories since it has to walk the whole subtree; can still be typed ad hoc when actually wanted.
- `lt` (2-level tree) vs `lta` (unlimited depth) — intentionally different depths, not an inconsistency.
- `cat` → `bat --paging=never --style=plain` — stripped to look like plain cat (no borders/line numbers, stays copy-pasteable/pipeable) but still keeps real syntax-highlight coloring, confirmed token-by-token on a `.py` file. Confirmed safe: aliases never reach scripts (they run in their own non-interactive shell, don't inherit interactive aliases at all), so nothing that depends on real `cat` behavior can break.
- `grep` → `grep --color=auto` — matches highlighted when run interactively, identical to plain `grep` when piped/scripted.
- Skipped `..`/`...` shortcuts — not wanted.
- `c='clear'`, `zr='exec zsh'`. Verified `exec zsh` is genuinely better than `source .zshrc` for a full reload — sourcing only adds/overwrites what's in the file, a stray function defined mid-session survives it; `exec zsh` starts a truly clean process.
- Installed `eza`, `bat`, `fzf`, `zoxide`, `fd`, `ripgrep` via Homebrew (a sandbox artifact earlier made `rg` look pre-installed when it wasn't — corrected).

## Tools (zoxide, fzf)

- `zoxide`: `eval "$(zoxide init zsh)"`, kept **last** in the file per the tool's own advice (its `__zoxide_doctor` self-check warns otherwise). Mechanism: it hooks `chpwd_functions` (zsh's built-in "directory changed" hook array) to silently log every `cd` into a frecency database — nothing polls or watches, it's purely reactive.
- `zl='zoxide query -ls'` — neither `zoxide --help` nor `z --help` explain `z`'s special forms (`z` alone → home, `z -` → previous dir, `z <path>` → direct cd, `z <query>` → frecency jump; confirmed `z --help` literally fails, "no match found," since `z` treats all args as a search query). Also added a `zh()` cheat-sheet function for this, then removed it — decided a lookup command you might forget exists doesn't actually solve "I forget the shortcuts" any better than this file does; `zl` survived because it's something actually used, not just a reference.
- `fzf`: used the modern `eval "$(fzf --zsh)"` one-liner instead of the inspiration repo's `source /opt/homebrew/opt/fzf/shell/*.zsh` loop — confirmed both produce identical output, but this version doesn't hardcode a Homebrew-specific path.
- Kept Ctrl-T (fuzzy file find) and Ctrl-R (fuzzy history search, upgrades the already-standard shell convention). **Dropped Alt-C** (fuzzy cd) on purpose: redundant with `zoxide`'s `zi`, and it doesn't even fire as-is — VSCodium's integrated terminal doesn't send the `Esc c` sequence fzf needs for Option+C by default (`terminal.integrated.macOptionIsMeta` is off), so the binding was explicitly unbound (`bindkey -r '\ec'`) rather than left silently non-functional.
- Pointed `fzf` at `fd` (`FZF_DEFAULT_COMMAND`/`FZF_CTRL_T_COMMAND`) instead of its own built-in walker — faster, and respects `.gitignore` automatically (verified: a gitignored test file was excluded by `fd`, present with fzf's bare default). Added a `bat`-powered preview pane for Ctrl-T.

## Plugins

The only two external plugins in the whole config, matching the inspiration repo's "no framework" approach — everything else so far is bare zsh.

- `zsh-autosuggestions` — shows the rest of a matching history entry as dimmed ghost text after the cursor, live per keystroke. Confirmed the real default accept bindings from the plugin source rather than assuming: `End`/`Right-arrow` accepts the whole suggestion, `Alt-Right` (`forward-word`) accepts it one word at a time — lines up with the `WORDCHARS`/word-motion setup from earlier. Kept the plugin's own default strategy (`history` only) rather than the inspiration repo's `(history completion)` fallback, since that's what was actually tested and confirmed working.
- `zsh-syntax-highlighting` — recolors the command line live (real command = one color, unrecognized = another, strings another). Sourced **last**, non-negotiably — it wraps every ZLE widget already defined, including `fzf`'s and `zsh-autosuggestions`', so anything sourced after it wouldn't get wrapped. Homebrew's install caveat mentioned a possible "highlighters directory not found" issue needing an extra `.zshenv` export — checked directly, doesn't apply here, the highlighters dir resolves correctly on its own.
- Both installed via `brew install` the same way as the other tools.

## How to: different config per terminal emulator

Several things in this setup (which `.p10k-*.zsh` prompt config loads, `eza --icons`, briefly) needed to behave differently depending on which terminal app the shell is running inside. The mechanism, reusable for anything else that comes up later:

1. **Read `$TERM_PROGRAM`.** Most terminal apps set this to identify themselves — confirmed real values on this machine: `vscode` (VSCodium), `Apple_Terminal` (Terminal.app), `ghostty` (Ghostty — verified directly from Ghostty's own source, `src/termio/Exec.zig`: `env.put("TERM_PROGRAM", "ghostty")`, not assumed). **Don't guess this value** — it's cheap to verify (`echo $TERM_PROGRAM` in the actual app, or check the terminal's source/docs) and guessing wrong silently breaks the branch.
2. **Branch on it** with a plain `case`:
   ```zsh
   case "$TERM_PROGRAM" in
     vscode|Apple_Terminal) ... ;;   # group terminals that should share behavior
     *)                     ... ;;   # fallback for everything else, including future terminals
   esac
   ```
   Always keep a `*` fallback — a terminal you haven't accounted for (or none at all, e.g. a script) should still get sane behavior, not silently break.
3. **Don't confuse this with `$EDITOR`/other env vars that change mid-session** — `$TERM_PROGRAM` is fixed for the life of the shell (you don't switch terminal apps mid-session), so it's safe to resolve once and even bake into a double-quoted alias without worrying about staleness, unlike something like `$EDITOR` which genuinely can change later.
4. **This only affects the shell**, not the app itself. VSCodium's own font settings (`terminal.integrated.fontFamily`) or Ghostty's `~/.config/ghostty/config` are separate, app-level config — `$TERM_PROGRAM` branching in `.zshrc` can't reach into those.

**Generating a separate P10k config per branch:** `p10k configure` always writes to whatever `$POWERLEVEL9K_CONFIG_FILE` points at (its own default, if unset, is `${ZDOTDIR:-~}/.p10k.zsh` — confirmed directly from P10k's `internal/configure.zsh` source, so it's already `ZDOTDIR`-aware without any extra setup). Prefixing the wizard command with a variable assignment overrides that *for just that one command*, without touching the parent shell's environment or the default file:
```zsh
POWERLEVEL9K_CONFIG_FILE=$ZDOTDIR/.p10k-terminal.zsh p10k configure
```
This is plain shell syntax (`VAR=value command`), not anything P10k-specific — the same trick works for overriding any env var for a single command without `export`ing it. Running the wizard this way produced a second, independent config file the `.zshrc` case statement could then pick between.

**Status: reverted.** Both examples of this pattern that existed in the live config — the prompt split above, and an earlier `eza --icons` split (Ghostty had a built-in Nerd Font, the other two didn't) — were removed once all three terminals reached equal capability (real Nerd Fonts installed and set as each app's actual terminal/editor font). Neither `.zshrc` currently branches on `$TERM_PROGRAM` for anything; both are back to one unconditional behavior for all terminals. The technique above is documented for whenever a *real* difference between terminals comes up again, not because it's in use right now.

## Deferred / open

- `$EDITOR`/`$VISUAL` not set yet — blocks `edit-command-line` and the `ze` alias (added once, removed once, for the same reason).
- Alt-C fix (VSCodium's `terminal.integrated.macOptionIsMeta` setting) — not worth doing, `zi` already covers the same job.
- AnnotationMono's Nerd Font build only ships Regular/Medium/Bold/ExtraBold (confirmed — the upstream font has Thin/ExtraLight/Light too, just not included in this particular patched build). No genuinely thinner-than-Regular weight available while keeping icon glyphs; self-patching the missing weights is possible but not done.

## Not yet in this file

This doc has drifted behind several real chunks of work — worth a fuller pass later: the Powerlevel10k prompt setup (instant-prompt, per-emulator config split, the `XDG_CACHE_HOME` cache-folder fix), Ghostty's own config (`~/.config/ghostty/config`, font size, discovering its bundled Nerd Font fallback), the full coordinated color palette (`colors.zsh`, now actually built — was listed as deferred above until this update), and the terminal font setup (`AnnotationM NFM`, `GoogleSansCode NFM` → Victor Mono, Iosevka Term NF) across all three apps.
