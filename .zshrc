# === Prompt ===
# Simple, informative prompt (or use Starship/Powerlevel10k for fancier)
PROMPT='%F{cyan}%~%f %F{green}❯%f '
RPROMPT='%F{242}%*%f' # timestamp on right

# Homebrew initialization
eval "$(/opt/homebrew/bin/brew shellenv)"

# === Aliases ===
alias ls='ls --color=auto' 

zmodload zsh/complist
autoload -U compinit && compinit
autoload -U colors && colors

# Completion opts
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive matching
zstyle ':completion:*' special-dirs true # complete . and ..
zstyle ':completion:*' squeeze-slashes true # normalize // to /
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f' # group descriptions
zstyle ':completion:*:warnings' format '%F{red}no matches found%f'

# Main opts
setopt append_history inc_append_history share_history
setopt auto_menu menu_complete
setopt autocd
setopt auto_param_slash
setopt no_case_glob no_case_match
setopt globdots
setopt extended_glob
setopt correct # spell correction for commands
setopt interactive_comments # allow comments in interactive shell
unsetopt prompt_sp

# History opts
HISTSIZE=500
SAVEHIST=500
setopt hist_ignore_dups # don't record duplicate consecutive entries
setopt hist_ignore_space # ignore commands starting with space
setopt hist_reduce_blanks # remove superfluous blanks
setopt hist_verify # show history expansion before running

# Key bindings for better navigation
# Would cycle through your ENTIRE history sequentially, ignoring what you've typed.
bindkey '^[[A' history-beginning-search-backward # up arrow
bindkey '^[[B' history-beginning-search-forward # down arrow
bindkey '^[[H' beginning-of-line # home
bindkey '^[[F' end-of-line # end
bindkey '^[[3~' delete-char # delete

# Load plugins last for better performance
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh