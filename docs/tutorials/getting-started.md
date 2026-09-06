# Setting up on a new Mac

A complete walk-through, from a machine with nothing installed to a working
shell. Follow it in order; each step has a checkpoint so you know it worked
before moving on.

Roughly 20 minutes, most of it waiting for downloads.

You will not need to understand the configuration to complete this. Once it
works, [docs/explanation/](../explanation/) covers why it is built the way it
is.

## Before you start

You need macOS with Apple's command line tools:

```bash
xcode-select --install
```

**Checkpoint** — this prints a path:

```bash
xcode-select -p
```

## 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The installer prints two commands to add Homebrew to your `PATH` at the end.
Run them — you need `brew` available for the next step. (The configuration will
handle this permanently later, via `.zprofile`.)

**Checkpoint:**

```bash
brew --version
```

## 2. Get the repository

```bash
git clone https://github.com/subidit/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
```

**Checkpoint** — this lists `Brewfile`, `install.sh`, `config`, `docs`:

```bash
ls
```

## 3. Install the tools

```bash
brew bundle install --file=Brewfile
```

This takes a while. It installs the shell plugins, the command-line
replacements, the editor, Ghostty and two fonts.

**Checkpoint** — every one of these prints a path:

```bash
for c in eza bat fd rg fzf zoxide fresh; do
  printf '%-8s %s\n' "$c" "$(command -v $c || echo MISSING)"
done
```

## 4. See what the installer will do

```bash
./install.sh --dry-run
```

Read the output. It lists the symlinks it will create and any existing file it
would move to `~/.dotfiles-backup/`. Nothing has been written yet.

## 5. Install

```bash
./install.sh
```

**Checkpoint** — this prints a path inside the repository:

```bash
readlink ~/.zshenv
```

## 6. Start the new shell

```bash
exec zsh
```

The prompt changes. If you see a warning about console output, something
printed during startup — see
[troubleshoot.md](../how-to/troubleshoot.md#p10k-warns-about-console-output-during-instant-prompt).

**Checkpoint** — history is in the right place and the palette compiled:

```bash
print $HISTFILE          # ~/.local/state/zsh/history
print ${#EZA_COLORS}     # a number in the hundreds
```

## 7. Switch to Ghostty

Open Ghostty from Applications. It picks up `~/.config/ghostty/config`
automatically, so you get JetBrains Mono at 16 px and the background the palette
is designed against.

**Checkpoint** — inside Ghostty:

```bash
echo $TERM $COLORTERM    # xterm-ghostty truecolor
```

If `$COLORTERM` is `truecolor`, you are getting 24-bit colour and the palette is
rendering exactly as designed.

## 8. Look at what you built

```bash
la
```

You should see: directories in blue, executables in green, permission bits in
three colour bands, file sizes shifting from cool to warm as they grow, and git
status flags on the left.

Try these:

| Command | What happens |
|---|---|
| `ll` | Long listing with git status and aligned ISO timestamps |
| `lt` | Two-level tree |
| type `cd ` then `Tab` | Coloured completion menu; `hjkl` to move |
| `^R` | Fuzzy search through history |
| `^T` | Insert a file path, with a preview |
| `z <dirname>` | Jump to a directory you have visited |
| start typing a past command | The rest appears in grey; `→` accepts it |
| `..` | Up one level |
| `d` | The numbered directory stack |

## 9. Confirm the home directory is clean

```bash
ls -A ~ | grep '^\.'
```

Expect around eight entries: `.DS_Store`, `.Trash`, `.cache`, `.config`,
`.local`, `.zshenv`, and whatever your own applications have added. Not the
fifty a normal setup accumulates.

## Done

Everything is symlinked, so editing a file in `~/Developer/dotfiles` changes
your shell in the next window.

Where to go next:

- [How-to guides](../README.md#how-to-guides) — specific tasks
- [Reference](../README.md#reference) — every alias, binding, option and colour
- [Explanation](../README.md#explanation) — why it is built this way

If something did not work, [troubleshoot.md](../how-to/troubleshoot.md) covers
the common cases, and `./install.sh --unlink` reverses everything.
