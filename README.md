# dotfiles

My macOS zsh setup. No plugin framework — every line is something I wrote and
understood, and the comments explain why it's there.

## Layout

```
.zshenv              # the only file zsh reads from $HOME; sets ZDOTDIR and gets out of the way
.config/zsh/
  .zprofile          # Homebrew shellenv (login shells only)
  .zshrc             # completion, options, history, keybindings, aliases, tools, prompt, plugins
  colors.zsh         # one OKLCH-tuned palette shared by eza, completion, fzf, highlighting
  .p10k.zsh          # prompt config — Ghostty, and the fallback for everything else
  .p10k-terminal.zsh # prompt config — Apple Terminal
  .p10k-custom.zsh   # overrides that survive `p10k configure` regenerating .p10k.zsh
.config/cache/       # generated: p10k instant-prompt, dump, gitstatus (untracked)
docs/                # tutorial, how-to, reference, explanation, decisions
```

`$HOME` stays clean: `.zshenv` points `ZDOTDIR` at `~/.config/zsh` and
`XDG_CACHE_HOME` at `~/.config/cache`, so every other startup file — plus
history, the completion dump, `less`'s search history and everything p10k
generates — lives under `.config` instead of scattered across the home
directory.

## What's in it

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
- **Prompt** — Powerlevel10k with instant prompt, a per-terminal config, and a
  24-bit palette solved for APCA contrast against the `#282c34` ground.

## Install

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting powerlevel10k \
             eza bat fzf fd zoxide

git clone https://github.com/subidit/dotfiles.git ~/dotfiles
ln -s ~/dotfiles/.zshenv     ~/.zshenv
ln -s ~/dotfiles/.config/zsh ~/.config/zsh

exec zsh
```

A Nerd Font is required for the prompt and `eza`'s icons.

## Docs

- [Tutorial](docs/tutorial.md) — set up a Mac terminal from scratch
- [How-to](docs/how-to.md) — task-oriented recipes
- [Reference](docs/reference.md) — what the config actually contains
- [Explanation](docs/explanation.md) — the reasoning behind its shape
- [Decisions](docs/decisions.md) — running log of what changed and why
