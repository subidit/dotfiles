# Environment variables

Set in [`home/.zshenv`](../../home/.zshenv) unless noted. `.zshenv` is read by
every zsh including non-interactive ones, so scripts inherit these too.

## XDG base directories

| Variable | Value |
|---|---|
| `XDG_CONFIG_HOME` | `~/.config` |
| `XDG_CACHE_HOME` | `~/.cache` |
| `XDG_DATA_HOME` | `~/.local/share` |
| `XDG_STATE_HOME` | `~/.local/state` |
| `ZDOTDIR` | `~/.config/zsh` |

## Editor

| Variable | Value |
|---|---|
| `EDITOR`, `VISUAL` | `fresh` |

`fresh` is terminal-native and blocks until you close the buffer, so it works
as a `git commit` editor without a `--wait` flag.

## Exiled dotfiles

Each of these moves a file that would otherwise land in `$HOME`.

| Variable | Destination |
|---|---|
| `LESSHISTFILE` | `$XDG_STATE_HOME/less/history` |
| `NPM_CONFIG_CACHE` | `$XDG_CACHE_HOME/npm` |
| `NODE_REPL_HISTORY` | `$XDG_STATE_HOME/node/repl_history` |
| `PYTHON_HISTORY` | `$XDG_STATE_HOME/python/history` (CPython ≥ 3.13) |
| `SQLITE_HISTORY` | `$XDG_STATE_HOME/sqlite/history` |
| `RIPGREP_CONFIG_PATH` | `$XDG_CONFIG_HOME/ripgrep/config` |
| `DOCKER_CONFIG` | `$XDG_CONFIG_HOME/docker` |
| `CARGO_HOME` | `$XDG_DATA_HOME/cargo` |
| `RUSTUP_HOME` | `$XDG_DATA_HOME/rustup` |
| `GOPATH` | `$XDG_DATA_HOME/go` |
| `GNUPGHOME` | `$XDG_DATA_HOME/gnupg` |
| `AWS_CONFIG_FILE` | `$XDG_CONFIG_HOME/aws/config` |
| `AWS_SHARED_CREDENTIALS_FILE` | `$XDG_CONFIG_HOME/aws/credentials` |
| `WGETRC` | `$XDG_CONFIG_HOME/wget/wgetrc` |
| `PI_CODING_AGENT_DIR` | `$XDG_CONFIG_HOME/pi/agent` |
| `SHELL_SESSIONS_DISABLE` | `1` — stops macOS creating `~/.zsh_sessions/` |

Several are preemptive: they cost nothing if the tool is never installed, and
they stop the file appearing the first time it is.

Tools that need no variable because they honour XDG natively: `git` (only if
`~/.gitconfig` does not exist), `bat`, `zoxide`, `gh`, `fresh`.

## Set in `.zshrc` (interactive only)

| Variable | Value | Purpose |
|---|---|---|
| `HISTFILE` | `$XDG_STATE_HOME/zsh/history` | |
| `HISTSIZE` / `SAVEHIST` | `200000` / `100000` | |
| `WORDCHARS` | `*?_-.[]~&;!#$%^(){}<>` | Excludes `/` and `=` so word motions stop at path boundaries |
| `LESS` | `-R -F -X -i -M --mouse --wheel-lines=3` | Colour, quit-if-one-screen, case-insensitive search |
| `MANPAGER` | `sh -c 'sed … \| bat -l man -p'` | Syntax-highlighted man pages |
| `MANROFFOPT` | `-c` | Required for the above to render correctly |
| `BAT_THEME` | `OneHalfDark` | Nearest bundled theme to the `#282c34` ground |
| `EZA_COLORS` | generated | Built from the palette table |
| `LS_COLORS` | generated | Built from the same table; also drives the completion menu |
| `FZF_DEFAULT_OPTS` | generated | Colours from the same table |
| `FZF_DEFAULT_COMMAND` | `fd --hidden --strip-cwd-prefix --exclude .git` | |
| `FZF_CTRL_T_COMMAND` | same as above | |
| `FZF_ALT_C_COMMAND` | `fd --type=d …` | |
| `FZF_CTRL_T_OPTS` | `--preview 'bat …'` | |

## Set in `.zprofile` (login shells)

| Variable | Purpose |
|---|---|
| `PATH` | Homebrew via `brew shellenv`, then `~/.local/bin` prepended |
