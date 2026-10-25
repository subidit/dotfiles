# Set up Node and npm without home clutter

> **Draft.** Written from the dry run on 2026-10-24 (macOS 27, Homebrew node 26.12.1, npm 12.2.1).

With Homebrew's Node, global packages already go to `/opt/homebrew`. Three things would still land in `~`:

| File or folder | Created when | Moved by |
|---|---|---|
| `~/.npm` | the first `npm install` | `npm_config_cache` |
| `~/.npmrc` | `npm login` or `npm config set …` | `npm_config_userconfig` |
| `~/.node_repl_history` | the first time you leave the `node` prompt | `NODE_REPL_HISTORY` |

**Before:**
- Don't run `npm` or `node` yet.
- If you already have `~/.npmrc`, move it after step 2: `mkdir -p ~/.config/npm && mv ~/.npmrc ~/.config/npm/npmrc`.

**Do:**

1. Add the variables to `~/.zshenv`:
   ```bash
   printf '\n# npm cache\nexport npm_config_cache="$XDG_CACHE_HOME/npm"\n' >> ~/.zshenv
   printf '\n# Node REPL history and npm config file\nexport NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"\nexport npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"\n' >> ~/.zshenv
   ```
2. Create the history folder:
   ```bash
   mkdir -p ~/.local/state/node
   ```
   Don't skip this. If the history folder is missing, Node prints "Could not open history file" and doesn't save your history. npm needs nothing: it creates `~/.config/npm` itself the first time it writes its config.
3. **Open a new terminal tab** (⌘T).
4. Check:
   ```bash
   print -D $NODE_REPL_HISTORY; npm config get cache userconfig | sed "s|=$HOME|=~|"
   ```
5. Start `node`, type something, then `.exit`.

**Expected:**
- Step 4 prints `~/.local/state/node/repl_history`, then `cache=~/.cache/npm` and `userconfig=~/.config/npm/npmrc`.
- After step 5, `ls ~/.local/state/node` shows `repl_history`, and `ls -A ~ | grep -iE 'node|npm'` prints nothing.

**Next:** install global CLIs with `npm install -g <package>`. They go to `/opt/homebrew/lib/node_modules`.

<!-- Verified 2026-10-24: NODE_REPL_HISTORY and npm_config_userconfig (dry run); missing-folder warning (tested in a scratch folder); npm_config_cache (earlier clean-home work). 2026-10-25: `npm config set` creates a missing npm config folder; the Node REPL saves no history without its folder (both tested in an empty scratch home). Not tested: pnpm, yarn, bun. -->
