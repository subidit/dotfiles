# ~/.config/zsh/.zshrc — interactive shell config (ZDOTDIR is set in ~/.zshenv)
# Order matters in two places only: compinit before any zstyle/completion use,
# and zsh-syntax-highlighting dead last.

# --- Palette ---
[[ -f ${ZDOTDIR:-$HOME}/colors.zsh ]] && source ${ZDOTDIR:-$HOME}/colors.zsh   # coordinated colors for eza, completion, fzf, syntax-highlighting, autosuggestions — optional, everything below works without it

# --- Shell options ---
setopt AUTO_CD               # a bare directory name and Enter is a cd
setopt EXTENDED_GLOB         # `^`/`~` negation in globs — `ls ^*.log` means everything but the logs
setopt GLOB_DOTS             # `*` sees dotfiles too, not just what a plain `ls` shows
setopt RM_STAR_WAIT          # a beat of hesitation before `rm *` — GLOB_DOTS just made that glob wider than it looks
setopt NO_CASE_GLOB          # `readme*` finds README.md
setopt INTERACTIVE_COMMENTS  # `#` works as a comment at the prompt, not just inside scripts
setopt PROMPT_SUBST          # allows substitution inside prompts; harmless and expected by many tools

# --- History ---
setopt HIST_IGNORE_DUPS        # a command identical to the one right before it doesn't get saved twice
setopt HIST_IGNORE_ALL_DUPS    # neither does one repeated anywhere earlier — the older copy is dropped instead
setopt HIST_SAVE_NO_DUPS       # the same rule, enforced again when the file hits disk
setopt HIST_FIND_NO_DUPS       # browsing skips duplicates without deleting them from the list
setopt HIST_EXPIRE_DUPS_FIRST  # if the list has to shrink, a duplicate goes before a unique old command does
setopt HIST_IGNORE_SPACE       # a leading space keeps a command out of history entirely
setopt HIST_REDUCE_BLANKS      # extra whitespace is trimmed before a line is saved
setopt SHARE_HISTORY           # every open tab sees the same history, live

# --- Completion ---
typeset -U fpath         # Homebrew's zsh build lists site-functions more than once; dedupe before compinit scans it
zmodload zsh/complist    # menu select renders nothing without this — the keymap it needs doesn't exist otherwise
autoload -Uz compinit
compinit                 # scans $fpath, wires up every TAB completer: _autocd, _git, _cd, all of it
zstyle ':completion:*' menu select          # an arrow-key navigable grid instead of flat TAB cycling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'   # case-insensitive, partial-match completion
zstyle ':completion:*' group-name ''        # matches labeled by type — commands, functions, aliases — not one flat dump
zstyle ':completion:*' use-cache on         # cache expensive completions like _git branch/tag lookups; $ZDOTDIR/.zcompcache

# --- Key bindings ---
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'   # the default swallows `/` and `=`, so word-motion jumped whole paths in one leap
bindkey '^U' backward-kill-line     # kill to the start of the line, not the whole line — the default eats text past the cursor too

autoload -Uz history-search-end                                 # history search that lands the cursor at end-of-line, never mid-word
zle -N history-beginning-search-backward-end history-search-end  # one widget name per direction, same function underneath
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^[[A' history-beginning-search-backward-end   # this terminal sends ^[[A for Up — $key[Up]/terminfo resolves empty here, so that lookup can't be trusted
bindkey '^[[B' history-beginning-search-forward-end

# --- Prompt ---
[[ -f ${ZDOTDIR:-$HOME}/prompt.zsh ]] && source ${ZDOTDIR:-$HOME}/prompt.zsh   # self-contained; defines its own colors, doesn't read colors.zsh

# --- Aliases ---
case "$TERM_PROGRAM" in
  Apple_Terminal) _eza_icons=never ;;    # Apple Terminal stays icon-free by design
  *)              _eza_icons=always ;;   # every other terminal gets them
esac
alias ls="eza --color=always --icons=$_eza_icons -1"   # one entry per line
alias ll="eza --color=always --icons=$_eza_icons -l --git --color-scale=size --color-scale-mode=fixed --no-user"   # permissions, size, git status — no owner column, no --total-size (too slow on real directories)
alias la="eza --color=always --icons=$_eza_icons -la --git --color-scale=size --color-scale-mode=fixed --no-user"   # ll plus hidden files
alias lt="eza --color=always --icons=$_eza_icons --tree --level=2 --git-ignore"    # two levels deep
alias lta="eza --color=always --icons=$_eza_icons --tree --git-ignore"             # unlimited depth
unset _eza_icons

alias cat='bat --paging=never --style=plain'   # cat's plain, pasteable shape with real syntax-highlight coloring underneath
alias grep='grep --color=auto'                 # highlighted when you're reading it, untouched the moment it's piped
alias zr='exec zsh'     # a genuinely clean reload — every startup file re-runs, nothing lingers from the old session
alias c='clear'

# --- Tools ---
# fzf
eval "$(fzf --zsh)"    # Ctrl-T fuzzy-finds a file, Ctrl-R fuzzy-searches history, Alt-C fuzzy-cd's
bindkey -r '\ec'       # Alt-C dropped — zoxide's `zi` already does this job
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'   # fd over fzf's own walker: faster, and it respects .gitignore
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"   # a live, syntax-highlighted preview pane

# zoxide
eval "$(zoxide init zsh)"     # z / zi — kept last in this block on zoxide's own advice
alias zl='zoxide query -ls'   # everything z has learned, ranked by score

# --- Plugins (syntax-highlighting must load last) ---
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh   # ghost text pulled from history; End or Right accepts it, Alt-Right takes it one word at a time
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # wraps every widget defined above it — nothing may load after this
