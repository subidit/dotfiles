export ZDOTDIR="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Keep agent CLI state out of $HOME dotfolders
export npm_config_cache="$XDG_CACHE_HOME/npm"
export CODEX_HOME="$XDG_CONFIG_HOME/codex"
export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"
export HERMES_HOME="$XDG_DATA_HOME/hermes"
export DSH_HOME="$XDG_DATA_HOME/dsh"
export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi/agent"
export DSH_AGENTS_HOME="$XDG_CONFIG_HOME/agents"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export DSH_TELEMETRY_MODE="DISABLED"
export DO_NOT_TRACK=1
export GOOSE_TELEMETRY_ENABLED=false
export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode"

# Python REPL history (Python 3.13+)
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"

# Node REPL history and npm config file
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"

# Rust: cargo downloads and installed tools
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Go: downloaded modules and installed tools (instead of ~/go)
export GOPATH="$XDG_DATA_HOME/go"

# Libraries agents pull in that ignore XDG on macOS (tested in a scratch home)
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"    # else ~/.matplotlib
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"         # else ~/.ipython
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter" # else ~/.jupyter
export KERAS_HOME="$XDG_DATA_HOME/keras"             # else ~/.keras
export NLTK_DATA="$XDG_DATA_HOME/nltk_data"          # else ~/nltk_data; the folder must exist
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"           # else ~/.rustup, if rustup is ever installed
