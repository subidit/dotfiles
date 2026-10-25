# Handoff: tidy-home, end of 2026-10-25 session

Read this first, then `scratchpad/decisions.md` (the full decisions log). Ask the user when something is unclear; don't assume beyond these two files.

## The project

A public, docs-first guide (Diátaxis) for keeping a macOS home folder minimal: Apple silicon, Homebrew, zsh. Everything by hand, with copy-paste commands. Folder: `~/Developer/tidy-home`. **Not a git repo yet**: ask before `git init`. `~/Developer/clean-home` is the read-only history of an earlier attempt.

The plan: finish the guide on the user's own Mac. Next, the user runs the guide in a **UTM macOS VM** (decided 2026-10-25) to test the steps marked **(untested)**; the factory reset of the real Mac comes after.

## How we work (the user's explicit preferences)

- One step at a time, shaped **Before → Do → Expected → Next**. The user runs it, then you check the files yourself and write what worked into the draft.
- **Order of events matters**, and the user asked for it to be remembered. For any relocation variable:
  1. `export` it in `~/.zshenv`
  2. `mkdir -p` its folder (Python and Node silently drop history otherwise)
  3. open a **new Ghostty tab**
  4. `echo $VAR` in that tab
  5. only then run the tool, and check `ls -A ~`

  In the dry run, cargo and go run in an old tab created `~/.cargo` and `~/go`.
- The `!` box in the Claude app runs in an old shell, and can't run interactive prompts. Send REPL and new-tab tests to real Ghostty.
- Confirm before installing or uninstalling, or changing `~/.zshenv`, LaunchAgents or app settings. Move to the Trash, never delete. Never print secrets. Your Bash can't list `~/.Trash`.
- Codex (ChatGPT) is reviewer and fact-checker only. It writes to `reviews/`, and Claude is the single writer of docs.

## Decisions (details in decisions.md)

- **No LaunchAgent** in the guide: the user doesn't want the "zsh" Login Item.
- **Allowed dotfolders (2026-10-25): `~/.codex`, `~/.dsh`, `~/.agents`**, so each CLI shares one folder with its desktop app. No `CODEX_HOME`, `DSH_HOME` or `DSH_AGENTS_HOME`. Plus `~/.ssh` as before. Nothing else.
- **Apps in:** Ghostty, VS Code (portable link `/Applications/code-portable-data` made before the first launch), Claude (its Desktop env setting for `CLAUDE_CONFIG_DIR`), **ChatGPT app**, **DeepSeek Harness app**, OpenCode, a browser. **Out:** Goose (dropped 2026-10-25), Hermes, Copilot CLI.
- **CLIs in:** Claude Code, Codex, dsh, Pi, OpenCode, gcloud. **Vertex AI** goes through OpenCode and Pi, with no Google Cloud lines in shell files.
- **Toolchains:**
  - Python (`PYTHON_HISTORY`, `brew install python3`, uv) — done;
  - Node (`NODE_REPL_HISTORY`, `npm_config_cache`, `npm_config_userconfig`) — done;
  - git and gh (empty `~/.config/git/config`; the user uses gh only) — done;
  - Rust (`CARGO_HOME`, Homebrew `rust`) — done;
  - Go (`GOPATH`) — done;
  - pnpm, yarn, bun, wget, gpg — skipped.
- **Shell tools in:** powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, fd, ripgrep, bat, eza, micro, fzf, zoxide.

## What exists

| File | State |
|---|---|
| `docs/tutorials/fresh-mac.md` | full first draft, 16 steps in 4 parts; `(untested)` marks |
| `docs/how-to/set-up-{python,node,git-and-gh,rust,go}.md` | drafts, each from verified dry-run steps |
| `HOME/` | skeleton of `~` after the tutorial's hand-made steps (2, 4, 5, 11, 14): blank files, `.gitkeep` in empty folders, `.config/zsh/.zshenv -> ../../.zshenv`. Every folder in it was checked to be one the tool won't create (decisions.md); `.config/npm` dropped. Codex's config is at `.codex/config.toml` (allowed dotfolder). Contents not filled in yet |
| `scratchpad/decisions.md` | decisions log, newest notes at the bottom of each section |
| `reviews/clean-home-audit.md` | Codex's audit of clean-home; its findings are folded into decisions.md |

## State of the user's Mac (verified 2026-10-25)

- `~` holds only `.CFUserTextEncoding .DS_Store .Trash .cache .config .local .zshenv` plus the standard folders.
- `~/.zshenv` sets: ZDOTDIR, the 4 XDG variables, npm_config_cache, CODEX_HOME, COPILOT_HOME, HERMES_HOME, DSH_HOME, PI_CODING_AGENT_DIR, DSH_AGENTS_HOME, CLAUDE_CONFIG_DIR, DSH_TELEMETRY_MODE, DO_NOT_TRACK, GOOSE_TELEMETRY_ENABLED, VSCODE_PORTABLE, PYTHON_HISTORY, NODE_REPL_HISTORY, npm_config_userconfig, CARGO_HOME, GOPATH. This is the old dry-run set: it still has `CODEX_HOME`, `DSH_HOME`, `DSH_AGENTS_HOME`, `HERMES_HOME` and `GOOSE_TELEMETRY_ENABLED`, which the guide no longer uses. Leave it until the user decides; the VM run uses the guide's block.
- `~/.config/zsh/.zshenv -> ../../.zshenv`. It fixes shells that inherit `ZDOTDIR`; tested.
- **Still installed from the old setup:** the LaunchAgents `local.xdg-env` and `local.clean-home-check`, Hermes (formula, cask, `~/.local/share/hermes`, three launchers in `~/.local/bin`), the ChatGPT and DeepSeek Harness apps. They stay until the user decides or resets; don't remove them without asking.
- fzf and zoxide are installed and in `.zshrc`. The `.zshrc` was reviewed against every tool's docs (see decisions.md, 2026-10-25). Completion dump in `~/.cache/zsh`; `EDITOR`/`VISUAL` = micro in `.zshrc`; Ghostty has `macos-option-as-alt = left` and the cursor-trail shader (the user commented out the block-cursor lines, so the cursor is a bar at the prompt).
- **Shortcut test passed, 2026-10-25:** all 18 rows in a restarted Ghostty (Option as Alt, word motion, Home/End, suggestion accept, Ctrl-X Ctrl-E, menu Tab/Shift-Tab, Ctrl-R, Ctrl-T, Alt-C, `z`, `-`, `zl`, `man` through bat, `GIT_EDITOR`, clean `~`). zoxide's database is at `~/Library/Application Support/zoxide/db.zo`.

## Open items, in suggested order

1. **Run the guide in the UTM macOS VM**, from step 1, one step at a time; record what each (untested) step actually does. **No real sign-ins in the VM** (user's choice): each tool is installed and launched to its sign-in screen, then quit. Anything written only after signing in (gh `hosts.yml`, Codex `auth.json`, dsh credentials, Claude app Code tab, OpenCode Copilot, Pi Vertex project) is left for the factory-reset run with real accounts. Results arrive as `scratchpad/vm/out-<step>.txt` via the shared folder.
2. **Before the factory reset:** get the repo off this Mac (`git init` + push, or copy), and decide on the old LaunchAgents, Hermes, ChatGPT and DeepSeek Harness apps (a reset removes them anyway).
2. **Read-only checker** `checker/tidy-check.sh`. Requirements from Codex's review: no writes at all (no logs, mkdir or notifications); catch non-dot clutter like `~/go`; a user-editable allowlist with opt-in exceptions (proposed at `~/.config/tidy-home/allowed`, not confirmed); "not checked" as its own result; never print environments or secrets. Telemetry checks only for tools the user opted into (not confirmed).
3. **Reference pages:** `docs/reference/home-entries.md` written 2026-10-25 (every entry that can appear in `~`, its fix and source; linked from tutorial Part 4; Bundler, RubyGems, Expo, mongosh unverified). `docs/reference/terminal-shortcuts.md` written 2026-10-25 (keys by kind of work, each with its source; linked from tutorial step 5). Still to write: variables, tools pass/fail matrix (include skipped and rejected tools, one line each), allowed entries, checker.
4. **Explanation pages:** why XDG, how desktop apps get variables (and why no LaunchAgent), the login race (as history), why not everything in `.config`.
5. **Optional how-tos:** migrate an existing Mac, telemetry, VS Code portable mode, audit a new tool, remove an app completely, and an optional LaunchAgent for people who want group-3 apps.
6. README, Brewfile, `templates/` (zshenv, zshrc plugin block, opencode.json).
7. Ask about `git init` and a license when it's time to publish.

## Untested items the factory-reset run must confirm

- Pi's `/login` storing the Vertex project;
- `~/.cache/zsh` created in step 2 before the first `compinit -d`;
- the ChatGPT app and Codex CLI sharing the sign-in and `~/.codex/config.toml`;
- the DeepSeek Harness app's first launch (signed in from `~/.dsh`?), and when `~/.agents` appears;
- the cause of `~/.npm` appearing with Pi (unconfirmed).
