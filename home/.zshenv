# ~/.zshenv — the only file zsh is willing to read from $HOME.
# Everything else lives under $ZDOTDIR. Sourced by *every* zsh (scripts
# included), so it stays declarative: exports only, no logic, no output.

# --- XDG base directories -------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"   # config      (versionable)
export XDG_CACHE_HOME="$HOME/.cache"     # regenerable
export XDG_DATA_HOME="$HOME/.local/share"# durable data
export XDG_STATE_HOME="$HOME/.local/state" # logs, history, "where was I"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# --- Editor ---------------------------------------------------------------
export EDITOR="fresh"
export VISUAL="fresh"

# --- Exile: tools that would otherwise litter $HOME -----------------------
# These belong here rather than in .zshrc so a *non-interactive* script that
# shells out to npm/less/python also writes to the right place.
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"       # CPython >= 3.13
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"
export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi/agent"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# macOS Terminal.app's per-session history shards; harmless to disable and it
# keeps ~/.zsh_sessions/ from ever appearing.
export SHELL_SESSIONS_DISABLE=1
