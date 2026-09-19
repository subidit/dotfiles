# dotfiles

My macOS zsh setup. No plugin framework and no prompt theme — every line is
something I wrote and understood, and the comments explain why it's there.

## Layout

```
.zshenv           # the only file zsh reads from $HOME; sets ZDOTDIR and gets out of the way
.config/zsh/
  .zprofile       # Homebrew shellenv (login shells only)
  .zshrc          # options, history, completion, keybindings, aliases, tools, plugins
  prompt.zsh      # the prompt — self-contained, defines its own colors
  colors.zsh      # one OKLCH-tuned palette shared by eza, completion, fzf, highlighting
.config/cache/    # generated state (untracked)
docs/             # tutorial, how-to, reference, explanation, decisions
```

`$HOME` stays clean: `.zshenv` points `ZDOTDIR` at `~/.config/zsh` and
`XDG_CACHE_HOME` at `~/.config/cache`, so every other startup file — plus
history, the completion dump and `less`'s search history — lives under
`.config` instead of scattered across the home directory.

## What's in it

- **Prompt** — plain zsh in its own file, no theme and no dependencies. Left:
  the path, with the folder you're in brighter than its ancestors, then a `❯`
  that turns red after a failure. Right: how long the last command took (past
  0.2s), a green `✓` or a red `✘` with the exit code, and a 12-hour clock.
- **Colors** — `colors.zsh` is one palette solved in OKLCH against the
  terminal's actual `#282c34` ground and shared by eza, the completion menu,
  fzf, zsh-syntax-highlighting and autosuggestions, so five tools stop using
  five unrelated default schemes. Two rules: lightness carries hierarchy, hue
  carries category. Optional — everything works without it.
- **Completion** — `menu select` grid, case-insensitive and partial matching,
  results grouped by type, expensive completers cached.
- **Options** — `AUTO_CD`, `EXTENDED_GLOB`, `GLOB_DOTS` (with `RM_STAR_WAIT` as
  the safety net), `NO_CASE_GLOB`, `INTERACTIVE_COMMENTS`.
- **History** — shared live across tabs, aggressively de-duplicated, and a
  leading space keeps a command out of it entirely.
- **Keybindings** — Up/Down do prefix history search landing at end-of-line;
  `WORDCHARS` retuned so word motion doesn't jump whole paths; `^U` kills
  backward only.
- **Tools** — `eza` (`ls`/`ll`/`la`/`lt`/`lta`), `bat` as `cat`, `fzf` with `fd`
  and a `bat` preview, `zoxide` for `z`/`zi`.

Interactive shell starts in about 40 ms; the prompt costs under 10 ms to
render, with no background daemon.

## Install

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting \
             eza bat fzf fd zoxide

git clone https://github.com/subidit/dotfiles.git ~/dotfiles
ln -s ~/dotfiles/.zshenv     ~/.zshenv
ln -s ~/dotfiles/.config/zsh ~/.config/zsh

exec zsh
```

A Nerd Font is required for `eza`'s icons and for the prompt's hourglass and
clock glyphs. Apple Terminal is detected and falls back to a glyph-free prompt
on its own; anywhere else without a patched font, set `PROMPT_POWERLINE=0`.

## Docs

- [Tutorial](docs/tutorial.md) — set up a Mac terminal from scratch
- [How-to](docs/how-to.md) — task-oriented recipes
- [Reference](docs/reference.md) — what the config actually contains
- [Explanation](docs/explanation.md) — the reasoning behind its shape
- [Decisions](docs/decisions.md) — running log of what changed and why
