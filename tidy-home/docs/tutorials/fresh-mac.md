# Set up a fresh Mac with a tidy home folder

> **Draft, updated 2026-10-25.** Built from the dry run on an existing Mac (macOS 27, Apple silicon). Steps marked **(untested)** come from reading the tool's own code or installer and haven't yet been run on a freshly reset Mac. The first real run after a factory reset will confirm or fix them.

By the end, the top of your home folder holds only:

```
.CFUserTextEncoding  .DS_Store  .Trash      ← macOS
.config  .cache  .local                     ← everything your tools write
.zshenv                                     ← the one file that has to stay in ~
.codex  .dsh  .agents                       ← shared by a CLI and its desktop app
Desktop  Developer  Documents  Downloads  Library  Movies  Music  Pictures  Public
```

No `.zshrc`, `.npm`, `.claude`, `.vscode`, `go` or `.cargo`. And no background "zsh" item in Login Items: this setup uses **no LaunchAgent**.

The three agent folders are allowed on purpose. The ChatGPT and DeepSeek Harness desktop apps don't read `~/.zshenv` when opened from the Dock, so they always use their default folders. Leaving Codex and dsh on the same defaults means each CLI and its app share one sign-in and one history.

**The one rule:** *every variable is set before the tool first runs.* Most clutter comes from a tool starting once without its variable. So the order of this tutorial matters, and three habits come up again and again:

1. After editing `~/.zshenv`, **open a new terminal tab**. Old tabs keep the old environment.
2. **Create the folder** a variable points to. Some tools silently do nothing if it's missing.
3. **Check with `echo $VARIABLE` in the same tab** right before a tool's first run.

---

## Part 1: The foundation

### 1. Finish Setup Assistant, and open nothing yet

**Do:** go through Setup Assistant as usual. When you reach the desktop, open **Terminal** (Applications → Utilities → Terminal) and nothing else.

**Expected:** a Terminal window with a `%` prompt.

**Next:** this first Terminal session has no settings yet, so it writes `~/.zsh_sessions` now and `~/.zsh_history` when it closes (both from macOS's own `/etc/zshrc` files). That's expected; you'll clean them up in step 3. (Checked on a fresh macOS 27 VM: step 3 moved exactly these two to the Trash.)

### 2. Write `~/.zshenv` and create the folders

zsh reads `~/.zshenv` for every shell, including the ones apps and agents start. It does two jobs here: points zsh's own files at `~/.config/zsh` (`ZDOTDIR`), and sets one folder variable per tool, **before any of those tools is installed**.

**Do:** paste this whole block into Terminal:

```bash
cat > ~/.zshenv <<'EOF'
# zsh: keep .zshrc, .zprofile and history in ~/.config/zsh
export ZDOTDIR="$HOME/.config/zsh"

# XDG base directories (these are the defaults; set so every tool agrees)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Python and Node
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"

# Libraries agents pull in on their own, which ignore XDG on macOS
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export KERAS_HOME="$XDG_DATA_HOME/keras"
export NLTK_DATA="$XDG_DATA_HOME/nltk_data"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Coding agents (Codex and dsh stay on ~/.codex, ~/.dsh and ~/.agents, shared with their apps)
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"
export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi/agent"

# VS Code portable mode (for VS Code started from a terminal; step 9 covers the Dock)
export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode"

# Telemetry off
export DSH_TELEMETRY_MODE=DISABLED
export DO_NOT_TRACK=1
EOF
```

Then create the folders that must exist before their tool runs:

```bash
mkdir -p ~/.config/{zsh,git} ~/.local/state/{python,node} ~/.local/share/{vscode,nltk_data} ~/.cache/zsh
touch ~/.config/zsh/.zshrc ~/.config/git/config
ln -s ../../.zshenv ~/.config/zsh/.zshenv
```

The last line matters because `ZDOTDIR` is exported. A zsh started *from* another shell or app that already has `ZDOTDIR` looks for `$ZDOTDIR/.zshenv` and skips `~/.zshenv`, so it would miss later edits. The link makes both names the same file. (Checked in the dry run: without the link, such a shell didn't see `PYTHON_HISTORY`; with it, it did.)

Why each one:

| Folder or file | Without it |
|---|---|
| `~/.config/zsh`, empty `.zshrc` | zsh can't save history there |
| `~/.cache/zsh` | step 5's `compinit -d` can't write its completion dump there |
| `~/.config/git/config` (empty) | `git config --global` writes `~/.gitconfig` instead |
| `~/.local/state/python`, `…/node` | Python and Node silently drop REPL history |
| `~/.local/share/vscode` | the VS Code link in step 9 would point at nothing |
| `~/.local/share/nltk_data` | NLTK ignores `NLTK_DATA` for downloads and writes `~/nltk_data` (no dot) |

The library variables (matplotlib, IPython, Jupyter, Keras, NLTK, rustup) are there because agents install these on their own, for a chart or a quick analysis. On macOS each one ignores XDG and would otherwise write to the top of `~`. All but NLTK create their own folder. Checked in a scratch home: matplotlib, IPython, Jupyter, NLTK; Keras and rustup from their code and docs.

**Expected:** no output from either command.

**Next:** **quit Terminal completely (⌘Q)**, not just the window. Then go to step 3.

### 3. Reopen Terminal and clean up the first session

**Do:** open Terminal again. Check the new settings took effect:

```bash
print -D $ZDOTDIR $CLAUDE_CONFIG_DIR
```

(`print -D` shows your home folder as `~`, so the output is the same on every Mac.)

Then move the first session's leftovers to the Trash:

```bash
mv ~/.zsh_history ~/.zsh_sessions ~/.Trash/ 2>/dev/null; ls -A ~
```

**Expected:**
- The first command prints `~/.config/zsh ~/.config/claude`.
- `ls -A ~` shows only `.CFUserTextEncoding`, `.Trash`, `.config`, `.cache`, `.local` and `.zshenv` (plus `.DS_Store` if Finder has been opened), and the normal folders.

If it prints nothing, you're in an old window: quit Terminal with ⌘Q and open it again.

**Next:** from now on, Terminal keeps its history in `~/.config/zsh`.

### 4. Install Homebrew

**Do:** run the official installer:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It installs Apple's Command Line Tools too; this takes a while.

**Expected:** it ends with **"Next steps"**: two `echo … >> …/.config/zsh/.zprofile` lines and an `eval` line. Because `ZDOTDIR` is already set, the installer points them at `~/.config/zsh/.zprofile`, not `~/.zprofile` (the installer's own code uses `${ZDOTDIR:-$HOME}/.zprofile`).

**Do:** check that path says `.config/zsh`, then paste the three lines it printed.

**Next:** **open a new tab (⌘T)**, then check:

```bash
command -v brew
```

It should print `/opt/homebrew/bin/brew`.

### 5. Install Ghostty and your shell tools

**Do:**

```bash
brew install --cask ghostty
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting fd ripgrep bat eza micro fzf zoxide
```

Don't run fzf's old `install` script (`$(brew --prefix)/opt/fzf/install`). It writes `~/.fzf.zsh` into your home. The `.zshrc` line below replaces it.

Install `fd` and `ripgrep` now, even if you don't use them yourself. Pi (step 15) and other agents look for them, and Pi downloads its own copies into `~/.config/pi/agent/bin` if they're missing. Installing them by name also keeps Homebrew from removing them later as unused dependencies.

Add the tools to `~/.config/zsh/.zshrc`. Order matters: completion first (zoxide needs it), fzf's settings before its `source` line, and syntax highlighting last:

```bash
cat >> ~/.config/zsh/.zshrc <<'EOF'

# Editor: git, gh and Ctrl-X Ctrl-E open it (only shells started from a terminal get it)
export EDITOR=micro VISUAL=micro

# Completion; its dump and cache can be rebuilt, so they go in ~/.cache/zsh
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# Keys zsh leaves unbound: Home, End, Alt-←/→ (End and Alt-→ also accept a suggestion)
bindkey '^[[H' beginning-of-line; bindkey '^[OH' beginning-of-line
bindkey '^[[F' end-of-line;       bindkey '^[OF' end-of-line
bindkey '^[[1;3C' forward-word;   bindkey '^[[1;3D' backward-word
autoload -Uz edit-command-line; zle -N edit-command-line
bindkey '^X^E' edit-command-line

# fzf: settings first, because the script reads *_COMMAND when it is sourced
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND='fd --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && eza -1 --color=always {} || bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always {}'"
source <(fzf --zsh)

# zoxide: z and zi
eval "$(zoxide init zsh)"

# Plugins (syntax-highlighting must load last)
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh
EOF
```

Why these choices:

- **`EDITOR` in `.zshrc`, not `.zshenv`:** only shells you start from a terminal get it. Agents' own shells keep their defaults.
- **The key bindings:** zsh binds none of Home, End or Alt-arrows by default, and zsh-autosuggestions accepts a suggestion through `end-of-line` and `forward-word`. Without these lines, End and Alt-→ do nothing.
- **fd for fzf:** it skips `.gitignore`'d files; fzf's own walker doesn't. `FZF_DEFAULT_COMMAND` is for plain `fzf` (files only); the shell integration uses `FZF_CTRL_T_COMMAND` (Ctrl-T, files and folders) and `FZF_ALT_C_COMMAND` (Alt-C, folders) instead.
- **zoxide's README says "end of file".** It sits above the plugins here so syntax highlighting can wrap its widget; its folder hook still registers.

Before opening Ghostty, make **left Option work as Alt**. Without it, Ghostty sends Alt only on the U.S. layouts, and elsewhere ⌥C types ç instead of opening fzf's folder picker, and ⌥B, ⌥F, ⌥← and ⌥→ do nothing in zsh. Right Option still types special characters:

```bash
mkdir -p ~/.config/ghostty
printf 'macos-option-as-alt = left\n' >> ~/.config/ghostty/config.ghostty
```

Open **Ghostty** from Applications, and quit Terminal. Powerlevel10k's setup wizard starts in the first tab. Its answers go to `~/.config/zsh/.p10k.zsh` because `ZDOTDIR` is set. Run `p10k configure` to redo it.

Where these tools keep their files (nothing in `~`):

| Tool | Files |
|---|---|
| Ghostty | `~/.config/ghostty` |
| powerlevel10k | `~/.config/zsh/.p10k.zsh`, cache in `~/.cache/p10k-*` |
| zsh completion | `~/.cache/zsh/zcompdump`, `~/.cache/zsh/zcompcache` |
| micro | `~/.config/micro` |
| zoxide | its folder database, `~/Library/Application Support/zoxide/db.zo` (macOS default; checked in the dry run) |
| fzf | nothing: `fzf --zsh` only prints its script (checked in the dry run) |
| bat, eza, fd, ripgrep | nothing written; optional config in `~/.config/<tool>` |

**Expected:** in Ghostty, `print -D $ZDOTDIR` prints `~/.config/zsh`, and `ls -A ~` still shows only the step 3 list. Ctrl-R opens fzf's history search, ⌥B moves back a word instead of typing ∫, and `ls ~/.cache/zsh` shows `zcompdump`.

Every key these tools add, and zsh's and Ghostty's own: [Terminal keyboard shortcuts](../reference/terminal-shortcuts.md).

**Next:** do everything from here on in Ghostty.

### 6. Turn off "Reopen windows"

Apps reopened at login start before anything else, which makes them hard to reason about. Turn it off once:

**Do:** the next time you restart or shut down, **untick "Reopen windows when logging back in"** in the dialog. macOS remembers it.

**Next:** don't add the apps in this tutorial to System Settings → General → Login Items → Open at Login.

---

## Part 2: Developer basics

### 7. git and GitHub CLI

`~/.config/git/config` already exists (step 2), so git writes its settings there.

**Do:**

```bash
brew install gh
gh auth login
```

Choose GitHub.com, HTTPS, and sign in with the browser.

**Expected:** `gh auth status` shows you logged in, with the token in the **keyring** (the Keychain). Its settings are in `~/.config/gh`.

### 8. Node and Python

**Do:**

```bash
brew install node python3 uv
```

**Next:** **open a new tab (⌘T)**, then check:

```bash
command -v node npm python3 uv; npm config get cache userconfig
```

**Expected:**
- every command is under `/opt/homebrew/bin`;
- npm's cache is `~/.cache/npm`;
- npm's config file is `~/.config/npm/npmrc`.

Details and REPL-history checks: [Set up Node](../how-to/set-up-node.md), [Set up Python](../how-to/set-up-python.md).

### 9. VS Code in portable mode

VS Code normally writes `~/.vscode`, `~/.vscode-shared` and `~/Library/Application Support/Code`. If a folder called `code-portable-data` sits next to the app, VS Code keeps everything there instead, with no variable needed, so it also works when opened from the Dock. A link counts.

**Do, before VS Code's first launch:**

```bash
ln -s ~/.local/share/vscode /Applications/code-portable-data
brew install --cask visual-studio-code
```

Open VS Code from Applications. Sign in to GitHub Copilot as usual.

**Expected:** `ls ~/.local/share/vscode` shows `user-data`, `extensions` and similar. `ls -A ~ | grep vscode` prints nothing, and `~/Library/Application Support/Code` doesn't exist. (Checked on a fresh macOS 27 VM, first launch from Applications.) VS Code's docs say portable mode doesn't work while the app is still quarantined, i.e. before macOS's "downloaded from the internet" prompt is accepted. If a first launch ever creates `~/.vscode`, quit, trash it, and open VS Code again.

**Copilot:** its files go to `~/.config/copilot`, and `ls -A ~ | grep copilot` prints nothing. VS Code reads your login shell's variables when it starts, even from the Dock, so it sees `COPILOT_HOME`. (Checked on the fresh VM, without a full Copilot sign-in.)

**Optional:** in Settings, set `telemetry.telemetryLevel` to `off`.

---

## Part 3: AI tools

Install in this order: Claude first (it needs one app setting before use), then the CLIs, then Google Cloud before the two tools that use Vertex AI.

### 10. Claude app and Claude Code

**Do:**

```bash
brew install --cask claude claude-code
```

1. Open **Claude** from Applications and sign in.
2. **Before using the Code tab**, copy the exact value to the clipboard in Ghostty:
   ```bash
   print -rn -- $CLAUDE_CONFIG_DIR | pbcopy
   ```
   Then in the Claude app: Code tab → the gear next to **Local** → Environment variables → add the name `CLAUDE_CONFIG_DIR`, and paste (⌘V) as its value. The app needs the full path, which is what this copies; `~` and `$HOME` don't work there.
3. In Ghostty: `claude`, then sign in.

**Expected:** `ls ~/.config/claude` shows Claude Code's files, including `.claude.json`. `ls -A ~ | grep claude` prints nothing.

Why the app setting: apps opened from the Dock never read `~/.zshenv`. This setting is how the Claude app's Code sessions get the variable without a LaunchAgent.

### 11. Codex CLI and the ChatGPT app (ChatGPT Plus)

Both use `~/.codex`, Codex's default. There's no `CODEX_HOME`: the app opened from the Dock would never see it, and the two would end up with separate sign-ins and settings.

**Do:** write the setting **before the first run**, then install both:

```bash
mkdir -p ~/.codex
printf '[analytics]\nenabled = false\n' >> ~/.codex/config.toml
brew install --cask codex chatgpt
codex login
```

Then open **ChatGPT** from Applications and sign in.

**Expected:** `ls ~/.codex` shows `config.toml`, `auth.json` and similar. `ls -A ~` shows `.codex` and no other new entry. **(untested on a fresh Mac: whether the app and the CLI share the sign-in and `config.toml`)**

### 12. DeepSeek Harness CLI and app

Both use dsh's defaults: `~/.dsh` for its home, and `~/.agents` for configuration it shares with other agent tools. There's no `DSH_HOME` or `DSH_AGENTS_HOME`, for the same reason as Codex.

**Do:**

```bash
npm install -g @deepseek-ai/dsh
brew install --cask deepseek-harness
cd "$(mktemp -d)" && dsh web
```

Open the address it prints, sign in with your DeepSeek account, then press Ctrl+C. Run it from an empty folder like this: DSH treats the folder it starts in as its workspace.

Then open **DeepSeek Harness** from Applications.

**Expected:** `ls -A ~/.dsh` shows `.credentials.yaml` and `profiles`, and the app is already signed in. `ls -A ~` shows `.dsh`, plus `.agents` once a feature that shares agent configuration is used, and no other new entry. (Checked on a fresh macOS 27 VM without signing in: `~/.dsh` holds `profiles`, `sessions` and `storages`, the app's default workspace goes to `~/Documents/deepseek-harness-default-workspace`, and `~/.agents` didn't appear yet. **Untested: whether the app and CLI share a sign-in.**)

Use the app, `dsh web` for a browser UI, or `dsh headless "<task>"` to run one task in Ghostty and print the result. dsh has no terminal UI of its own.

Watch out: `brew install dsh` is an unrelated tool.

### 13. Google Cloud sign-in for Vertex AI

**Do:**

```bash
brew install --cask gcloud-cli
gcloud auth login
gcloud projects list --format='table(projectId, name)'
```

The last command lists your projects. Set the one with your Vertex AI credits, replacing `<project-id>` with its `PROJECT_ID`:

```bash
gcloud config set project <project-id>
gcloud auth application-default login
```

Steps 14 and 15 read the project back from `gcloud config get-value project`, so this is the only place you type it.

**Expected:** `ls ~/.config/gcloud` shows `application_default_credentials.json`. Pi and OpenCode find it there by default.

There are no Google Cloud lines in `~/.zshenv`: each tool keeps the project in its own settings.

### 14. OpenCode (Copilot and Vertex AI)

**Do:** write its Vertex settings **before the first run**, then install. The project comes from step 13:

```bash
project=$(gcloud config get-value project 2>/dev/null); echo "project: $project"
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.json <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "google-vertex": {
      "options": { "project": "$project", "location": "global" }
    }
  }
}
EOF
brew install opencode
brew install --cask opencode-desktop
opencode auth login
```

If the first line prints `project:` with nothing after it, go back to step 13 before going on. In `opencode auth login`, choose GitHub Copilot.

**Expected:** `opencode models | grep google-vertex/gemini` lists Gemini models. `ls -A ~ | grep opencode` prints nothing (it uses `~/.config/opencode`, `~/.local/share/opencode`, `~/.local/state/opencode`).

### 15. Pi

**Before:** `fd` and `ripgrep` are installed (step 5). `command -v fd rg` prints two paths under `/opt/homebrew/bin`.

**Do:**

```bash
brew install pi-coding-agent
gcloud config get-value project | tr -d '\n' | pbcopy
pi
```

The second line copies your project ID to the clipboard. Inside Pi, run `/login` → **Google Vertex AI** → **Application Default Credentials**. When it asks for the project, paste (⌘V); for the location, type `global`.

**Expected:** Pi answers using a Vertex model. `ls ~/.config/pi/agent` shows `auth.json`, and `ls -A ~ | grep -x .pi` prints nothing. **(untested: storing the project through `/login`, read from Pi 1.4's code)**

---

## Part 4: Check

**Do:**

```bash
ls -A ~
```

**Expected:** the list at the top of this page, and nothing else.

If something extra appears, its name usually tells you which tool ran without its variable. Move it to the Trash, open a new tab, check the tool's variable with `echo`, and run the tool again. For an entry this tutorial doesn't cover, look it up in [Entries that can appear in `~`](../reference/home-entries.md).

<!-- To add when written: the read-only checker (checker/tidy-check.sh) as the final step; optional how-tos for Rust (CARGO_HOME), Go (GOPATH), telemetry. -->
