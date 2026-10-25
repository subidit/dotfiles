# Set up Go without home clutter

> **Draft.** Written from the dry run on 2026-10-24 (macOS 27, Homebrew go 1.27.3).

| What | Default | Clutter? |
|---|---|---|
| `GOPATH`: downloaded modules (`pkg/mod`) and `go install` binaries (`bin`) | `~/go` | **yes** |
| build cache (`GOCACHE`) | `~/Library/Caches/go-build` | no |
| `go env -w` settings, telemetry data | `~/Library/Application Support/go/` | no |

So only `GOPATH` needs moving.

**Before:** don't run `go` until step 4.

**Do:**

1. Add the variable and create its folder:
   ```bash
   printf '\n# Go: downloaded modules and installed tools (instead of ~/go)\nexport GOPATH="$XDG_DATA_HOME/go"\n' >> ~/.zshenv
   mkdir -p ~/.local/share/go
   ```
2. **Open a new terminal tab** (⌘T) and do the rest there.
3. Install: `brew install go`
4. **In the same tab, check right before the first run:**
   ```bash
   print -D $GOPATH
   ```
   Stop if it prints nothing.
5. Test by installing a tiny tool:
   ```bash
   cd "$(mktemp -d)" && go install golang.org/x/example/hello@latest
   ```

**Expected:**
- Step 4 prints `~/.local/share/go`.
- `go env GOPATH GOMODCACHE` shows both under `~/.local/share/go`.
- `ls $GOPATH` shows `bin pkg`, and `ls -A ~ | grep -x go` prints nothing.

**If `~/go` appeared anyway:** go ran in a tab without the variable. It happened in the dry run. `mv ~/go ~/.Trash/`, open a new tab, and run it again.

**Telemetry:** `go env GOTELEMETRY` shows `local` by default: Go records usage stats on your Mac (`~/Library/Application Support/go/telemetry`) and uploads nothing. `go telemetry off` stops even that.

**Next:** binaries from `go install` go to `$GOPATH/bin`. Add that to PATH in `~/.config/zsh/.zprofile` only if you use them.
