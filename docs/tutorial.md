# Tutorial: set up a Mac terminal from scratch

Learning-oriented. Follow in order; each step builds on the last. Uses zsh (macOS default), Homebrew, and no plugin framework — every line is something you typed and understood, not copied from a theme.

## 1. Install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Move zsh config out of `$HOME`

zsh always reads `~/.zshenv` first, no matter what — that's the one file that can't move. Everything else can live in `~/.config/zsh/` if `.zshenv` points there:

```zsh
mkdir -p ~/.config/zsh
cat > ~/.zshenv <<'EOF'
export ZDOTDIR="$HOME/.config/zsh"
EOF
```

Move your PATH setup into `~/.config/zsh/.zprofile` (login shells only — runs once, not on every nested shell):

```zsh
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' > ~/.config/zsh/.zprofile
```

Create `~/.config/zsh/.zshrc` — this is where everything below goes. Open a new terminal after each step to test it.

## 3. Core shell options

```zsh
autoload -Uz compinit
compinit
setopt AUTO_CD EXTENDED_GLOB GLOB_DOTS RM_STAR_WAIT NO_CASE_GLOB INTERACTIVE_COMMENTS
```

`AUTO_CD` = type a bare directory name to `cd` into it. `RM_STAR_WAIT` = safety pause before `rm *`, needed because `GLOB_DOTS` makes `*` match dotfiles too.

## 4. History

```zsh
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY
```

`SHARE_HISTORY` is the one that matters most — live-syncs history across every open tab.

## 5. Install the core tools

```zsh
brew install eza bat fzf zoxide fd ripgrep
```

`eza`=better `ls`, `bat`=better `cat`, `fzf`=fuzzy finder, `zoxide`=smarter `cd`, `fd`=better `find`, `ripgrep`=better `grep`.

## 6. Aliases

```zsh
alias ls="eza --color=always -1"
alias ll="eza --color=always -l --git --no-user"
alias cat='bat --paging=never --style=plain'
alias grep='grep --color=auto'
```

## 7. Wire up fzf and zoxide

```zsh
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
eval "$(zoxide init zsh)"   # gives you `z` and `zi`; keep this near the end of .zshrc
```

## 8. Prompt

```zsh
brew install powerlevel10k
echo 'source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.config/zsh/.zshrc
echo '[[ -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] && source ${ZDOTDIR:-$HOME}/.p10k.zsh' >> ~/.config/zsh/.zshrc
```

Open a new terminal, run `p10k configure`, follow the wizard.

## 9. Plugins — the only two, and order matters

```zsh
brew install zsh-autosuggestions zsh-syntax-highlighting
echo 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.config/zsh/.zshrc
echo 'source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.config/zsh/.zshrc
```

`zsh-syntax-highlighting` must be the last line in the whole file — it wraps every widget defined above it.

## 10. Icons (optional)

```zsh
brew install --cask font-symbols-only-nerd-font   # or a full Nerd Font
```

Set that font as your terminal's font, then add `--icons=always` to the `eza` aliases from step 6.

You now have a working, understood terminal setup. See `how-to.md` for specific tasks, `reference.md` to look things up, `explanation.md` for the reasoning.
