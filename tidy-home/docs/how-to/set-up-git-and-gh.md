# Set up git and gh without home clutter

> **Draft.** Written from the dry run on 2026-10-24 (macOS 27, Apple git 2.54 from the Command Line Tools, gh 2.103.0).

| Tool | Writes to | Home clutter risk |
|---|---|---|
| gh | `~/.config/gh` (config.yml, hosts.yml); token in the Keychain | none: XDG by default |
| git | `~/.config/git/config` **only if that file exists** and `~/.gitconfig` doesn't | `~/.gitconfig` |
| git HTTPS passwords | Apple's default helper `osxkeychain` (the Keychain) | `~/.git-credentials` if you ever switch to the `store` helper; don't |

## Make git write its settings to `~/.config/git`

git's `--global` settings go to `~/.gitconfig`, unless `~/.config/git/config` already exists and `~/.gitconfig` doesn't (from the `git config` documentation). So create the file first, even empty, even if you never set anything yourself. Other tools may run `git config --global` for you.

**Before:** do this before any `git config --global`, and before `gh auth setup-git`.

**Do:**
```bash
mkdir -p ~/.config/git && touch ~/.config/git/config
```

**Expected:** `ls ~/.config/git` shows `config`, and `ls -A ~ | grep -i git` prints nothing.

**Next:**
- Sign in to GitHub with `gh auth login`. It stores the token in the Keychain and its settings in `~/.config/gh`.
- If you later set your identity (`git config --global user.name …`), check it landed in the right file: `git config --global --list --show-origin`.

<!-- Verified 2026-10-24: gh folders and Keychain login (gh auth status); empty ~/.config/git/config present, no ~/.gitconfig. Not yet run in the dry run: a git config --global write. -->
