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

No theme, no framework — the prompt is a file you write. Start with the
smallest thing that works, in `~/.config/zsh/prompt.zsh`:

```zsh
PROMPT='%F{cyan}%~%f %F{green}❯%f '
RPROMPT='%F{242}%D{%l:%M %p}%f'
```

`%~` is the current directory, `%F{…}`/`%f` set and clear a color, `%D{…}` is
strftime. Source it from `.zshrc`:

```zsh
echo '[[ -f ${ZDOTDIR:-$HOME}/prompt.zsh ]] && source ${ZDOTDIR:-$HOME}/prompt.zsh' >> ~/.config/zsh/.zshrc
```

Open a new terminal. To show anything that changes *between* commands — an exit
status, how long the last one took — you need a `precmd` hook, which zsh runs
right before drawing each prompt:

```zsh
autoload -Uz add-zsh-hook
_p_precmd() {
  local code=$?          # must be the first line: anything else overwrites $?
  (( code == 0 )) \
    && RPROMPT="%F{green}✓%f" \
    || RPROMPT="%F{red}✘ $code%f"
}
add-zsh-hook precmd _p_precmd
```

Build up from there — the finished version in this repo adds the elapsed time
(via a `preexec` hook and `$EPOCHREALTIME`), the clock, and a split-color path.
Check your work without opening a new shell by running `_p_precmd` and printing
the result with `print -rP -- "$PROMPT"`.

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
