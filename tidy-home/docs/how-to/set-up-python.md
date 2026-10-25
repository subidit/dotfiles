# Set up Python without home clutter

> **Draft.** Written from the dry run on 2026-10-24 (macOS 27, Homebrew Python 3.14.9, uv 0.13.5). Steps marked *pending* haven't been tested yet.

## REPL history

Typing in the interactive Python prompt (`>>>`) saves your history to `~/.python_history` when you exit. Python 3.13 and later read `PYTHON_HISTORY` instead, if it's set.

**Before:** close any open `python` prompts.

**Do:**

1. Add the variable to `~/.zshenv`:
   ```bash
   printf '\n# Python REPL history (Python 3.13+)\nexport PYTHON_HISTORY="$XDG_STATE_HOME/python/history"\n' >> ~/.zshenv
   ```
2. Create its folder:
   ```bash
   mkdir -p ~/.local/state/python
   ```
   Don't skip this. If the folder is missing, Python silently doesn't save your history: no error, no file.
3. **Open a new terminal tab** (⌘T). Tabs that were already open still have the old environment.
4. Check:
   ```bash
   print -D $PYTHON_HISTORY
   ```
5. Start `python3`, type something, then `exit()`.

**Expected:**
- Step 4 prints `~/.local/state/python/history`.
- After step 5, `ls ~/.local/state/python` shows `history`, and `ls -A ~ | grep -i python` prints nothing.

**Watch out:** Apple's `/usr/bin/python3` (3.9, from the Command Line Tools) doesn't know `PYTHON_HISTORY`. Its code hardcodes `~/.python_history`, and running it recreated that file even with the variable set. The next section makes plain `python3` mean a current Python.

**Next:** if `~/.python_history` exists from before, move it to the Trash (`mv ~/.python_history ~/.Trash/`), or append it to the new file first if you want to keep it.

## A current `python3`

Plain `python3` is Apple's 3.9 until something earlier on PATH provides it. Homebrew's versioned Pythons (`python3.14`…) don't link an unversioned `python3`; `brew install python3` does.

**Do:**
1. `brew install python3`
2. **Open a new terminal tab** (⌘T). zsh remembers where it found commands, so an old tab may still run Apple's.
3. Check:
   ```bash
   command -v python3 pip3; python3 --version
   ```

**Expected:** `/opt/homebrew/bin/python3`, `/opt/homebrew/bin/pip3`, and a current version (3.15.0 in the dry run).

## pip and uv need nothing

| Tool | Folder | Note |
|---|---|---|
| pip cache | `~/.cache/pip` | follows `XDG_CACHE_HOME` |
| pip config | `~/.config/pip/pip.conf` | only read; created only if you run `pip config set` |
| uv cache, Pythons, tools | `~/.cache/uv`, `~/.local/share/uv/…` | XDG by default |
| project environments | `.venv` inside each project | made by `uv init` / `uv add` |

`pip3 install <package>` outside an environment fails with `externally-managed-environment`. That's Homebrew protecting its Python, and it also keeps installs out of `~`. Use uv projects instead:

```bash
uv init demo && cd demo && uv add requests && uv run python -c 'import requests; print("ok")'
```

<!-- Verified 2026-10-24: python3 → Homebrew 3.15.0; pip cache/config dirs (pip cache dir, pip config debug); uv init/add/run made .venv in the project, ~ unchanged. Not tested for v1: uv tool (bins in ~/.local/bin, not on PATH), pyenv, IPython (IPYTHONDIR), Jupyter (JUPYTER_CONFIG_DIR). -->


