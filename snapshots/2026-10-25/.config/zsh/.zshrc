# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Shell options ---
setopt AUTO_CD               # a bare directory name and Enter is a cd
setopt EXTENDED_GLOB         # `^`/`~` negation in globs — `ls ^*.log` means everything but the logs
setopt GLOB_DOTS             # `*` sees dotfiles too, not just what a plain `ls` shows
setopt RM_STAR_WAIT          # a ten-second wait before `rm *` can be confirmed — GLOB_DOTS just made that glob wider than it looks
setopt NO_CASE_GLOB          # `readme*` finds README.md
setopt INTERACTIVE_COMMENTS  # `#` works as a comment at the prompt, not just inside scripts
setopt PROMPT_SUBST          # allows substitution inside prompts; harmless and expected by many tools

# --- Editor ---
export EDITOR=micro   # git, gh and Ctrl-X Ctrl-E open this; set here, so only shells started from a terminal get it
export VISUAL=micro

# --- History ---
HISTFILE="$ZDOTDIR/.zsh_history"   # macOS's /etc/zshrc sets the same; stated here so nothing depends on Apple's file
HISTSIZE=5000
SAVEHIST=4000
setopt HIST_IGNORE_ALL_DUPS    # a command repeated anywhere earlier isn't kept twice — the older copy is dropped instead
setopt HIST_SAVE_NO_DUPS       # the same rule, enforced again when the file hits disk
setopt HIST_FIND_NO_DUPS       # browsing skips duplicates without deleting them from the list
setopt HIST_IGNORE_SPACE       # a leading space keeps a command out of history entirely
setopt HIST_REDUCE_BLANKS      # extra whitespace is trimmed before a line is saved
setopt SHARE_HISTORY           # every open tab sees the same history, live

# --- Completion ---
typeset -U fpath         # Homebrew's zsh build lists site-functions more than once; dedupe before compinit scans it
zmodload zsh/complist    # compinit loads it for menu select anyway; loading it here lets `bindkey -M menuselect` work at startup
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"   # the dump is a rebuildable cache, so it lives in ~/.cache/zsh (folder must exist)
zstyle ':completion:*' menu select          # an arrow-key navigable grid instead of flat TAB cycling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|=*' '+l:|=* r:|=*'   # case-insensitive, then partial-match; `+` keeps each earlier rule instead of replacing it
zstyle ':completion:*' group-name ''        # matches labeled by type — commands, functions, aliases — not one flat dump
zstyle ':completion:*' use-cache on         # cache expensive completions like _git branch/tag lookups
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"   # next to the dump, instead of $ZDOTDIR/.zcompcache

# ── Line-editing cheat sheet (emacs keymap) ─────────────────────────────
#
#  Words  (a "word" stops at / and = because of WORDCHARS below)
#    Ctrl-W      delete word before cursor
#    Alt-D       delete word after cursor
#    Alt-B       move back one word
#    Alt-F       move forward one word
#    Alt-← / →   the same as Alt-B / Alt-F (left Option is Alt in Ghostty)
#
#  Line
#    Ctrl-U      delete from cursor to start of line (text after cursor stays)
#    Ctrl-K      delete from cursor to end of line
#    Ctrl-A      jump to start of line   (Home, fn-←, too)
#    Ctrl-E      jump to end of line     (End, fn-→, too)
#    Ctrl-Y      paste back the last thing deleted
#    Ctrl-X Ctrl-E   edit the line in micro; save and quit to put it back
#
#  Suggestions (grey ghost text from history)
#    → or End    accept all of it
#    Alt-→       accept the next word
#
#  Completion and files
#    Tab / Shift-Tab   step forwards / backwards through the menu
#    Ctrl-T      fzf: pick files or folders, pasted at the cursor
#
#  History
#    Up          previous command starting with what's typed before the cursor
#    Down        next command starting with that same prefix
#                (empty line = plain step through all history;
#                 cursor lands at end of each match)
#    Ctrl-R      fzf fuzzy search over all history (Enter puts it on the line, Esc cancels)
#
#  Folders
#    Alt-C       fzf: pick any folder below here and cd into it
#    z <part>    jump to a folder you've visited   zi  pick one with fzf
#    -           back to the previous folder       mkcd <dir>  make it and step in
#
#  Aliases
#    ll / la / lt   eza long / with dotfiles / tree    homels  the tidy-home check
#    m  micro   ezrc / ezenv / eghostty  edit configs   fe  fuzzy-pick a file into micro
#    zr  restart zsh   zl  zoxide's ranked folders      c  clear
#
#  Debug
#    Ctrl-V <key>   print the raw sequence a key sends (Up should be ^[[A)
# ────────────────────────────────────────────────────────────────────────

# --- Key bindings ---
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'   # the default swallows `/` and `=`, so word-motion jumped whole paths in one leap
bindkey '^U' backward-kill-line     # kill to the start of the line, not the whole line — the default eats text past the cursor too

autoload -Uz history-search-end                                 # history search that lands the cursor at end-of-line, never mid-word
zle -N history-beginning-search-backward-end history-search-end  # one widget name per direction, same function underneath
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^[[A' history-beginning-search-backward-end   # this terminal sends ^[[A for Up — $key[Up]/terminfo resolves empty here, so that lookup can't be trusted
bindkey '^[[B' history-beginning-search-forward-end

bindkey '^[[H' beginning-of-line; bindkey '^[OH' beginning-of-line   # Home (fn-← on a Mac keyboard) — unbound by default
bindkey '^[[F' end-of-line;       bindkey '^[OF' end-of-line         # End (fn-→); also accepts a whole suggestion
bindkey '^[[1;3C' forward-word;   bindkey '^[[1;3D' backward-word    # Alt-→/←; Alt-→ also takes a suggestion one word at a time

autoload -Uz edit-command-line; zle -N edit-command-line
bindkey '^X^E' edit-command-line                    # open the current line in $EDITOR; save and quit to put it back
bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift-Tab steps backwards through the completion menu

# --- Aliases ---
alias zr='exec zsh'     # restart zsh in place: re-reads .zshenv and .zshrc, not .zprofile; exported variables carry over
alias c='clear'
# new names only below — agents can pick up these aliases, so nothing may shadow a real command like `ls`

# listing: eza under its own names, `ls` stays stock
alias ll='eza -l --git --group-directories-first'    # long list with a git status column
alias la='eza -la --git --group-directories-first'   # the same, with dotfiles
alias lt='eza --tree --level=2 --git-ignore'         # two-level tree, skipping .gitignore'd files
alias homels='ls -A ~'                               # the tidy-home check: compare with the allowed list

# navigation (AUTO_CD already makes a bare `..` or `../..` work)
alias -- -='cd -'                                    # back to the previous folder
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }           # make a folder and step into it

# editing (micro)
alias m='micro'
alias ezrc='micro $ZDOTDIR/.zshrc'
alias ezenv='micro ~/.zshenv'
alias eghostty='micro ~/.config/ghostty/config.ghostty'
fe() { local f; f=$(fzf --preview 'bat --color=always --style=numbers --line-range=:200 {}') && micro "$f"; }   # fuzzy-pick a file, open it in micro


# --- Tools ---
# fzf (settings first: the script reads *_COMMAND when it is sourced)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'   # plain `fzf`: files only, skipping .gitignore'd ones
export FZF_CTRL_T_COMMAND='fd --hidden --follow --strip-cwd-prefix --exclude .git'             # Ctrl-T: files and folders, like fzf's own walker, but .gitignore-aware
export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && eza -1 --color=always {} || bat --color=always --style=numbers --line-range=:200 {}'"   # a live preview: folder listing, or syntax-highlighted file
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --strip-cwd-prefix --exclude .git'   # Alt-C: folders only, .gitignore-aware
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always {}'"                                  # preview: what's inside
source <(fzf --zsh)         # Ctrl-R fuzzy history (replaces zsh's own Ctrl-R), Ctrl-T file picker, Alt-C cd into a folder below

# bat as the man pager (plain text passes through when the output isn't a terminal)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# zoxide
eval "$(zoxide init zsh)"     # z / zi — zoxide says end of file; kept above the plugins so syntax-highlighting can wrap its widget (hook checked)
alias zl='zoxide query -ls'   # everything z has learned, ranked by score


# --- Plugins (syntax-highlighting must load last) ---
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh   # ghost text pulled from history; End or Right accepts it, Alt-Right takes it one word at a time
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # wraps every widget defined above it — nothing may load after this

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
