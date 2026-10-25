# Decisions log

Working notes for tidy-home. Newest first within each section. Not part of the published docs.

## Plan

- **2026-10-24:** No VM for now. Continue on my own Mac (user `subidit`) and test the dev toolchains there. Later: factory-reset this Mac and follow the finished guide for real. (UTM is installed; the VM plan is parked.)
- Every step, here and in the docs, follows **Before → Do → Expected → Next**, and says explicitly when to quit and reopen Ghostty or Terminal, quit an app, or set a variable before the first run.
- Codex is a reviewer and fact-checker only: it writes to `reviews/`, and Claude is the single writer of docs.

## Agents (2026-10-25, supersedes the Tools table below where they differ)

- **In:** Claude Code + Claude app, Codex CLI, **ChatGPT app** (back in), OpenCode, Pi, DeepSeek Harness CLI **and app** (app back in), VS Code + Copilot.
- **Out:** **Goose** (dropped; Vertex AI now through OpenCode and Pi only), Hermes, Copilot CLI.
- Defaults the desktop apps use when opened from the Dock (no variables): ChatGPT app → `~/.codex` (Codex docs); DeepSeek Harness app → `~/.dsh` and `~/.agents` (dsh's `dsh-home-paths`: `DSH_HOME_DIR_NAME = ".dsh"`, `AGENTS_HOME_DIR_NAME = ".agents"`, the latter "shared with other agent tools").
- **Allowed dotfolders (decided 2026-10-25): `~/.codex`, `~/.dsh`, `~/.agents`.** App and CLI share one folder each, so no split sign-ins or histories, and still no LaunchAgent. Consequence: drop `CODEX_HOME`, `DSH_HOME`, `DSH_AGENTS_HOME` from `.zshenv`. No other agent gets a dotfolder: Claude, OpenCode, Pi and VS Code keep their relocation. (`~/.ssh` stays allowed as before.)
- Guide changes this implies (made 2026-10-25; the VM run checks them): tutorial `.zshenv` block; step 2 `mkdir` (no `~/.config/codex`); step 11 writes `~/.codex/config.toml`; step 12 expected paths; Goose step 16 and `GOOSE_TELEMETRY_ENABLED` removed; the "top of `~`" list gains `.codex .dsh .agents`; `HOME/` gets `.codex/config.toml` instead of `.config/codex`; ChatGPT and DeepSeek Harness apps get their own steps. To check in the VM: Codex creates `~/.codex` itself when `CODEX_HOME` is unset; where each app writes on first launch.

## LaunchAgent

- **2026-10-24: none.** I don't want the "zsh" item in Login Items → Allow in the Background. So the guide only includes desktop apps that need no variable, or that have their own setting.
- Consequence: desktop apps that only read a relocation variable (ChatGPT, DeepSeek Harness app) are out. The repair script and the login-race defences aren't needed for the core guide.
- Still do: turn off "Reopen windows when logging back in".

## Tools

| | In | Out |
|---|---|---|
| **Apps** | Ghostty, VS Code (for GitHub Copilot Pro; portable mode via the `/Applications/code-portable-data` link, made before the first launch), Claude (Desktop setting for `CLAUDE_CONFIG_DIR`), OpenCode, Goose, a browser | ChatGPT app (use chatgpt.com + Codex CLI), DeepSeek Harness app (use `dsh web`), Hermes app |
| **CLIs** | Claude Code, Codex, dsh (`dsh web` / `dsh headless`; shipped profiles are `acp`, `desktop`, `headless`, `web`, no `tui`), Pi, OpenCode, Goose, gcloud | Hermes, Copilot CLI (VS Code covers Copilot Pro) |

- **Vertex AI credits:** OpenCode, Goose and Pi. None of them gets Google Cloud lines in `~/.zshenv` or `.zshrc`; each keeps the project in its own config.
  - OpenCode: `provider.google-vertex.options.project` / `location` in `~/.config/opencode/opencode.json`. **Verified 2026-10-24** on OpenCode 2.1.3 with no Google Cloud variables set: `gemini-4-argon` answered, and nothing new appeared in `~`.
  - Pi 1.4: `/login` → Google Vertex AI → Application Default Credentials asks for the project and location and stores them in `auth.json`. Read from Pi's code, **not yet tested**.
  - All three need `gcloud auth application-default login` first.
- **Goose and OpenCode: both (2026-10-24).** Goose is the general assistant, filling the Hermes-shaped gap (`schedule`, Telegram `gateway`, recipes, skills, local models). OpenCode is the coding agent for Copilot Pro and Vertex AI.
  - Goose's Vertex setup keeps the project in `~/.config/goose/config.yaml` (`goose configure`); worked in the earlier session.
  - To test before Goose's extras go into the guide: whether `goose schedule` / `goose gateway` keep running with the app closed, and whether that adds a login item; where `goose local-models` stores downloads.

## Still to test (on my Mac)

**Python, done for v1 (2026-10-24):** REPL history via `PYTHON_HISTORY` verified; Apple's `/usr/bin/python3` ignores it (verified). `brew install python3` verified (python3 → Homebrew 3.15.0). pip (`~/.cache/pip`, `~/.config/pip`) and uv (XDG, `.venv` per project) need nothing; verified. Not tested for v1: uv tool, pyenv, IPython, Jupyter.

**Node, done (2026-10-24):** `NODE_REPL_HISTORY` and `npm_config_userconfig` verified, next to the existing `npm_config_cache`. pnpm, yarn and bun: I don't use them, not tested for v1.

**Skipped for v1 (2026-10-24, I don't use them):** pnpm, yarn, bun. They get one line each in the tools reference, from docs only.

**Rust and Go, done (2026-10-24):** `CARGO_HOME` (Homebrew `rust`, no rustup) and `GOPATH` verified. The first runs happened in an old tab and created `~/.cargo` and `~/go`; trashed, and a rerun in a new tab was clean. So the guide has a "check the variable in the same tab right before the first run" step.

**git:** I use gh only. No identity set for now, but the guide still creates an empty `~/.config/git/config` so any later `git config --global` writes there instead of `~/.gitconfig`.

**Shell utilities (2026-10-24):** less already uses `~/.local/state/lesshst`; curl only reads a config; ssh is the allowed `~/.ssh` exception. wget and gpg: not installed, not needed by agents; reference lines only (`WGETRC`, `GNUPGHOME`). (git and gh: draft written; a `git config --global` write not yet run.)

Also to check: whether the VS Code Copilot extension writes `~/.copilot` (VS Code opened from the Dock gets no `COPILOT_HOME` from launchd).

## Open items from the handoff

1. ~~LaunchAgent `sed` step~~: moot, no LaunchAgent.
2. Allowlist file at `~/.config/tidy-home/allowed`: not confirmed.
3. Telemetry checks only for tools I opted into: not confirmed.
4. Revert VS Code / remove Hermes on my account: Hermes is out of the guide; whether to uninstall it now isn't decided.
5. ~~Repo name~~: **tidy-home**.

## Writing

- **2026-10-24:** first draft of `docs/tutorials/fresh-mac.md`, in four parts: foundation (`.zshenv` first, then Homebrew), developer basics, AI tools, check.
  - Verified while drafting: Homebrew's installer prints its PATH lines for `${ZDOTDIR:-$HOME}/.zprofile`, so writing `.zshenv` before Homebrew makes its "Next steps" safe to paste. macOS `/etc/zshrc` and `/etc/zshrc_Apple_Terminal` put history and sessions in `${ZDOTDIR:-$HOME}`.
  - Untested on a fresh Mac (marked in the page): the first Terminal session's leftovers, VS Code link-only on first launch, the Copilot extension and `COPILOT_HOME`, Pi's `/login` Vertex project.
- **2026-10-24, from Codex's review (`reviews/clean-home-audit.md`):**
  - Confirmed its finding that a zsh which inherits `ZDOTDIR` skips `~/.zshenv`. Fix added to the tutorial, step 2: `ln -s ../../.zshenv ~/.config/zsh/.zshenv` (tested in a scratch folder). **Not yet applied on my own Mac.**
  - Added VS Code's quarantine caveat; softened "Codex needs the folder".
  - Taken on board for the checker: read-only (no logs, no mkdir, no notifications), catch non-dot clutter like `~/go`, opt-in exceptions, report "not checked" separately, never print environments or secrets.
  - Taken on board for docs: no repair script, no timestamp-based trashing; placeholders instead of my real project ID.
- **2026-10-25:** `~/.config/zsh/.zshenv` link added on my Mac. The first attempt pointed at itself (`-> .zshenv`); repointed to `../../.zshenv`, and a shell with only `ZDOTDIR` now sees `PYTHON_HISTORY`.
- **2026-10-25:** tutorial step 5 now installs my shell tools: powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, fd, ripgrep, bat, eza, micro. It adds the `.zshrc` plugin lines, and p10k's file goes in `$ZDOTDIR`. All checked on my Mac: nothing in `~`.
- **2026-10-25, Pi and `~/.npm`:** I saw `~/.npm` appear when Pi was installed before fd/ripgrep. From Pi 1.4's code, missing fd/rg are downloaded from GitHub into `$PI_CODING_AGENT_DIR/bin`, not through npm. Homebrew's own npm build uses Homebrew's cache. Pi does run `npm` for `pi install` packages and self-update, inheriting the shell's `npm_config_cache`. **Cause not confirmed;** most likely npm ran once without the variable. Either way, the tutorial installs fd and ripgrep before Pi. ripgrep is currently only a dependency (of hermes-agent and opencode) on my Mac, so `brew autoremove` could drop it.
- **2026-10-25:** fzf and zoxide added to tutorial step 5 (`source <(fzf --zsh)`, `eval "$(zoxide init zsh)"`, after compinit and before syntax-highlighting). Avoid fzf's old install script, which writes `~/.fzf.zsh`. **Untested:** neither is installed on my Mac yet; zoxide's macOS database location is from its docs.
- **2026-10-25, `.zshrc` review against each tool's official docs** (fzf README and its 0.74.5 script, zoxide/p10k/autosuggestions/syntax-highlighting READMEs, zsh 5.9 man pages, fd/bat/eza `--help`). fzf and zoxide installed on my Mac; tutorial step 5 updated to match:
  - fzf: settings go **before** `source <(fzf --zsh)` (it decides bindings from `*_COMMAND` at source time). Alt-C off with `FZF_ALT_C_COMMAND=''`; `bindkey -r` only cleared the emacs keymap. fd for `.gitignore` (not speed): `--type f` for plain `fzf`, files and folders for Ctrl-T, `--follow` like fzf's own walker. Preview handles folders with eza.
  - zsh leaves Home, End and Alt-←/→ unbound, so autosuggestions' End/Alt-→ accept did nothing. Bound them.
  - `matcher-list` entries replace each other unless prefixed with `+`; fixed so partial matches stay case-insensitive.
  - `HIST_IGNORE_DUPS` and `HIST_EXPIRE_DUPS_FIRST` dropped: no-ops next to `HIST_IGNORE_ALL_DUPS`. `HISTFILE` set explicitly instead of relying on `/etc/zshrc`.
  - zoxide stays above the plugins (its README says end of file); its hook registers, and syntax-highlighting can wrap its widget.
  - Completion dump and cache moved to `~/.cache/zsh` (`compinit -d`, `cache-path`); the folder must exist first, so tutorial step 2 creates it. Old `.zcompdump` trashed.
- **2026-10-25, Ghostty cursor (personal, not in the tutorial):** the thin cursor came from Ghostty's shell integration, which sets a bar at every prompt; `shell-integration-features = no-cursor` keeps `cursor-style = block`. The animation is a custom shader, `~/.config/ghostty/shaders/cursor-trail.glsl`: a glowing, flickering streak from `iPreviousCursor` to `iCurrentCursor` on jumps of 2+ cells, and a pulsing halo at rest. (A first try, a plain fade, wasn't what I meant; trashed.) Blink off so it doesn't fight the shader.
- **2026-10-25, `docs/reference/terminal-shortcuts.md`:** every key in the setup, grouped by kind of work, each with its source (zsh, zsh completion, tty, .zshrc, .zshrc extra, fzf, autosuggestions, Ghostty, less, micro). Found while writing it: Ghostty already sends Alt-B/F for Alt-←/→; Delete (fn-Backspace) is unbound in zsh; Ctrl-S/Ctrl-Q are flow control.
- **2026-10-25, startup time (personal, not in the tutorial):** about 68 ms warm vs 12 ms for bare zsh; p10k's instant prompt hides most of it. Tried a once-a-day `compinit` check (`-C` otherwise): 68 → 62 ms (zprof had suggested ~15 ms). Not worth the extra lines; reverted to a plain `compinit -d`.
- **2026-10-25, which folders must exist before the tool runs** (each tested against an empty scratch home unless noted). Drives `HOME/` and tutorial step 2.
  - **Must exist:** `~/.config/zsh` (history: "locking failed"); `~/.cache/zsh` (`compinit -d` silently writes no dump); `~/.local/state/python`, `~/.local/state/node` (REPLs silently save no history); `~/.config/git/config` the *file* (`git config --global` writes `~/.gitconfig` otherwise, even when the folder exists); `~/.local/share/vscode` (VS Code's `existsSync()` follows the link; a dangling one means not portable; read from its `mainImpl.js`); `~/.config/codex` (Codex errors "failed to resolve CODEX_HOME").
  - **Must exist only because we write config before the first run:** `~/.config/ghostty`, `~/.config/opencode` (each made in its own step).
  - **Tool creates it itself:** `~/.config/npm` (`npm config set`; dropped from step 2 and `HOME/`), `~/.config/gh`, `~/.config/claude`, `~/.config/pi/agent`, `~/.config/gcloud`, `~/.local/share/dsh` (`dsh --profile web --dump-config`), OpenCode's data/state/cache, `~/.local/state/goose`, `~/.config/micro` (from micro's source, `os.MkdirAll`), `~/.cache/npm`.
  - **Not tested:** `~/.config/goose` (made by interactive `goose configure`), `~/.config/agents` (dsh; doesn't exist on my Mac either), `~/.config/copilot` (VS Code extension).
- **2026-10-25, library variables:** a Codex session plotting a chart (venv + matplotlib) created `~/.matplotlib`; on macOS matplotlib only honours `MPLCONFIGDIR` (its `_get_config_or_cache_dir`). Added to my `.zshenv` and the tutorial: `MPLCONFIGDIR`, `IPYTHONDIR`, `JUPYTER_CONFIG_DIR` (tested in a scratch home with uv: each moves, IPython and matplotlib create their folder), `NLTK_DATA` (tested: ignored for downloads unless the folder exists, so step 2 creates `~/.local/share/nltk_data`), `KERAS_HOME` (Keras source: read first, folder created), `RUSTUP_HOME` (rustup docs). Skipped `TS_NODE_HISTORY`. `~/.matplotlib` trashed.
- **2026-10-25, `docs/reference/home-entries.md`:** lookup table of entries in `~` with fix type (handled / allowed / variable / folder / partial / none) and source. Notable from the checks: IRB switches to `~/.config/irb` once that folder exists (no variable); Gemini CLI's `GEMINI_CLI_HOME` gets a `.gemini` inside it; Windsurf now uses `~/.config/devin`; `CONTINUE_GLOBAL_DIR` and `SQLITE_HISTORY` are in code but not docs; `.cursor`, `.streamlit` have no variable. Variables not added to `.zshenv` for tools I don't use.
- **2026-10-25, VM run (steps 1–9):** `~` clean throughout. VS Code's portable link works on first launch; Copilot writes `~/.config/copilot` (VS Code reads the login shell's variables even from the Dock), no `~/.copilot`. `~/.config/gh` missing because the user didn't finish `gh auth login` (no real sign-ins in the VM). Step 11 check: `~/Library/Application Support/Code` absent (step 9 marks removed); Claude Code before sign-in writes only `~/.config/claude` (`.claude.json`, `settings.json`, `backups`, `cache`, `sessions`); Codex writes `~/.codex` (`config.toml`, `log`, `tmp`), the only new entry in `~`. Terminal can't list `~/.Trash` (TCC); in Finder the Trash held exactly `.zsh_history` and `.zsh_sessions`, so step 1's mark is removed. Step 12 check: `~` gained only `.dsh` (with `.credentials.yaml`, `profiles/web`, `sessions`, `storages`); no `~/.agents` yet; the dsh app's default workspace is `~/Documents/deepseek-harness-default-workspace`. VM run stopped after step 12 (2026-10-25); steps 13–15 and all sign-ins move to the factory-reset run.
- **2026-10-25, Alt-C back on:** it was off only because Option typed ç. With Option as Alt (`cat -v` shows `^[c`), fzf's folder picker is back: `FZF_ALT_C_COMMAND='fd --type d --hidden --follow --strip-cwd-prefix --exclude .git'`, eza preview. It differs from `zi`: any folder below here vs. folders already visited.
- **2026-10-25, Ghostty:** with `macos-option-as-alt` unset, Ghostty treats Option as Alt only on U.S. layouts; on mine ⌥C typed ç. Set `macos-option-as-alt = left` in `~/.config/ghostty/config.ghostty`. Added to tutorial step 5.
- **2026-10-25, `EDITOR`/`VISUAL` = micro in `.zshrc`, not `.zshenv`:** only terminal shells get it; agents' shells keep their defaults. Verified a non-interactive zsh has no `EDITOR`.
- **2026-10-25, aliases:** new names only, never shadowing a real command (agents can pick up interactive aliases): `ll la lt homels - mkcd m ezrc ezenv eghostty fe`. Avoided `cc` (C compiler), `tidy`, `trash` (`/usr/bin/trash` exists; use it), `pi`, `gs`. Homebrew, git/gh, Python and agent aliases: not added. Also added: Ctrl-X Ctrl-E, Shift-Tab in the menu, bat as `MANPAGER` (piped output stays plain). These personal extras are in my `.zshrc` only, not the tutorial.
