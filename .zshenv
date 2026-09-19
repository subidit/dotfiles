export ZDOTDIR="$HOME/.config/zsh"   # everything else (.zprofile, .zshrc) lives here instead of $HOME
export SHELL_SESSIONS_DISABLE=1      # stop Terminal.app from creating ~/.zsh_sessions/
export XDG_CACHE_HOME="$HOME/.config/cache"   # keeps generated cache out of $HOME; p10k writes instant-prompt/dump/gitstatus here
export LESSHISTFILE="$ZDOTDIR/lesshst"   # less's search-history file defaults to ~/.lesshst otherwise
