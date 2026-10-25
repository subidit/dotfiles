# Entries that can appear in `~`

What each file or folder at the top of the home folder is, what creates it, and how to keep it out. For a Mac set up with [the fresh Mac tutorial](../tutorials/fresh-mac.md) on macOS 27.

Checked on 2026-10-25 against each tool's documentation or source code. The **Source** column says which.

## Fix types

| Fix | Meaning |
|---|---|
| **Handled** | The tutorial already prevents it |
| **Allowed** | Kept on purpose in this setup |
| **Variable** | Set the variable in `~/.zshenv`, open a new tab, then run the tool |
| **Folder** | Create the folder; the tool uses it once it exists |
| **Partial** | The variable moves only part of it; the rest stays |
| **None** | No documented way to move it |

Desktop apps opened from the Dock don't read `~/.zshenv`. A variable fixes only the command-line tool, unless the app has its own setting or reads the login shell (VS Code does).

## Entries

| Entry | Created by | Fix | What to set | Source |
|---|---|---|---|---|
| `.agents` | DeepSeek Harness | Allowed | — | dsh code (`dsh-home-paths`) |
| `.android` | Android SDK tools | Variable | `ANDROID_USER_HOME` | Android docs |
| `.aws` | AWS CLI | Partial | `AWS_CONFIG_FILE`, `AWS_SHARED_CREDENTIALS_FILE`, `AWS_CLI_HISTORY_FILE` move those files only | AWS CLI docs |
| `.azure` | Azure CLI | Variable | `AZURE_CONFIG_DIR` | Azure CLI docs |
| `.bun` | Bun | Variable | `BUN_INSTALL`, set before installing | Bun docs |
| `.cargo` | Cargo | Handled | `CARGO_HOME` | [Set up Rust](../how-to/set-up-rust.md) |
| `.claude`, `.claude.json` | Claude Code | Handled | `CLAUDE_CONFIG_DIR`, plus the Claude app's setting | Tutorial step 10 |
| `.cocoapods` | CocoaPods | Variable | `CP_HOME_DIR` | CocoaPods source |
| `.codex` | Codex CLI, ChatGPT app | Allowed | — | Codex docs |
| `.continue` | Continue | Variable | `CONTINUE_GLOBAL_DIR` | Continue source (not in its docs) |
| `.copilot` | GitHub Copilot | Handled | `COPILOT_HOME` | Tutorial step 9 |
| `.cursor` | Cursor | None | — | Cursor docs |
| `.docker` | Docker CLI | Variable | `DOCKER_CONFIG` (the CLI only; Docker Desktop doesn't see it) | Docker docs |
| `.dsh` | DeepSeek Harness | Allowed | — | dsh code |
| `.fly` | flyctl | Variable | `FLY_CONFIG_DIR` | flyctl source |
| `.gemini` | Gemini CLI | Variable | `GEMINI_CLI_HOME`; it creates `.gemini` *inside* that path | Gemini CLI docs |
| `.gnupg` | GnuPG | Variable | `GNUPGHOME` | GnuPG manual |
| `go` | Go | Handled | `GOPATH` | [Set up Go](../how-to/set-up-go.md) |
| `.gradle` | Gradle | Variable | `GRADLE_USER_HOME` | Gradle docs |
| `.ipython` | IPython | Handled | `IPYTHONDIR` | Tested |
| `.irbrc`, `.irb_history` | Ruby's IRB | Folder | `mkdir -p ~/.config/irb`; IRB then uses `irbrc` and `irb_history` there | IRB source (`rc_file_generators`) |
| `.jupyter` | Jupyter | Handled | `JUPYTER_CONFIG_DIR` | Tested |
| `.keras` | Keras | Handled | `KERAS_HOME` | Keras source |
| `.kube` | kubectl | Partial | `KUBECONFIG` moves the config file; the cache needs `--cache-dir` on each command | kubectl reference |
| `.m2` | Maven | Partial | `<localRepository>` in `~/.m2/settings.xml` moves the repository; `.m2` itself stays | Maven docs |
| `.matplotlib` | matplotlib | Handled | `MPLCONFIGDIR` | Tested |
| `.mcp-auth` | `mcp-remote` (MCP servers that sign in) | Variable | `MCP_REMOTE_CONFIG_DIR` | mcp-remote README |
| `.mysql_history` | mysql client | Variable | `MYSQL_HISTFILE` | MySQL manual |
| `nltk_data` | NLTK | Handled | `NLTK_DATA`, and its folder must exist | Tested |
| `.node_repl_history` | Node | Handled | `NODE_REPL_HISTORY` | [Set up Node](../how-to/set-up-node.md) |
| `.npm`, `.npmrc` | npm | Handled | `npm_config_cache`, `npm_config_userconfig` | [Set up Node](../how-to/set-up-node.md) |
| `.ollama` | Ollama | Partial | `OLLAMA_MODELS` moves the models; its key stays in `.ollama` | Ollama FAQ |
| `.psql_history`, `.psqlrc` | psql | Variable | `PSQL_HISTORY`, `PSQLRC` | PostgreSQL docs |
| `.pub-cache` | Dart, Flutter | Variable | `PUB_CACHE` | Dart docs |
| `.python_history` | Python | Handled | `PYTHON_HISTORY`; Apple's `/usr/bin/python3` ignores it | [Set up Python](../how-to/set-up-python.md) |
| `.rediscli_history`, `.redisclirc` | redis-cli | Variable | `REDISCLI_HISTFILE`, `REDISCLI_RCFILE` | Redis docs |
| `.rustup` | rustup | Handled | `RUSTUP_HOME` | rustup docs |
| `.sdkman` | SDKMAN! | Variable | `SDKMAN_DIR`, set before installing | SDKMAN! docs |
| `.sqlite_history` | sqlite3 | Variable | `SQLITE_HISTORY` | Read from the macOS `sqlite3` binary (not in sqlite's docs) |
| `.ssh` | ssh | Allowed | — | — |
| `.streamlit` | Streamlit | None | — | Streamlit docs |
| `.supabase` | Supabase CLI | None | Only appears when the keychain is unavailable | Supabase docs |
| `.vscode`, `.vscode-shared` | VS Code | Handled | Portable-mode link | Tutorial step 9 |
| `.zsh_history`, `.zsh_sessions`, `.zshrc`, `.zprofile` | zsh, Terminal | Handled | `ZDOTDIR` | Tutorial step 2 |

## Already outside `~`

Tools agents commonly use that need nothing, because on macOS they already write to `~/Library`, `~/.cache`, `~/.config` or `~/.local`: pip, uv, Poetry, pipx, Hugging Face, PyTorch, Go's build cache, node-gyp, Playwright, Puppeteer, Deno, corepack, gh, gcloud, OpenCode, Pi, micro, less, and Windsurf (now `~/.config/devin`).

## Not verified

These came up but couldn't be confirmed in the tool's own docs or source:

| Entry | Created by | Likely fix |
|---|---|---|
| `.bundle` | Bundler | `BUNDLE_USER_HOME` |
| `.gem`, `.gemrc` | RubyGems | `GEM_HOME`; newer RubyGems may use `~/.local/share/gem` |
| `.expo` | Expo | — |
| `.mongodb` | mongosh | — |
