# Set up Rust without home clutter

> **Draft.** Written from the dry run on 2026-10-24 (macOS 27, Homebrew rust 1.99.1).

cargo keeps its download cache and the tools you `cargo install` in `~/.cargo`, unless `CARGO_HOME` is set. This guide uses Homebrew's `rust` (rustc and cargo straight on PATH). If you install `rustup` instead, also set `RUSTUP_HOME`, or it creates `~/.rustup`.

**Before:** don't run `cargo` until step 4.

**Do:**

1. Add the variable and create its folder:
   ```bash
   printf '\n# Rust: cargo downloads and installed tools\nexport CARGO_HOME="$XDG_DATA_HOME/cargo"\n' >> ~/.zshenv
   mkdir -p ~/.local/share/cargo
   ```
2. **Open a new terminal tab** (⌘T) and do the rest there.
3. Install: `brew install rust`
4. **In the same tab, check right before the first run:**
   ```bash
   print -D $CARGO_HOME
   ```
   Stop if it prints nothing. You're in a tab opened before step 1.
5. Test with a throwaway project that downloads one dependency:
   ```bash
   cd "$(mktemp -d)" && cargo new hello && cd hello && cargo add itoa && cargo build
   ```

**Expected:**
- Step 4 prints `~/.local/share/cargo`.
- Step 5 ends with `Finished`.
- `ls $CARGO_HOME` shows `registry`, and `ls -A ~ | grep -i cargo` prints nothing.

**If `~/.cargo` appeared anyway:** cargo ran in a tab without the variable. It happened in the dry run. It's only cache, so `mv ~/.cargo ~/.Trash/`, open a new tab, and run it again.

**Next:** tools from `cargo install` go to `$CARGO_HOME/bin`. Add that to PATH in `~/.config/zsh/.zprofile` only if you install any.
