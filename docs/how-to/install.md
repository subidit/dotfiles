# How to install, update and uninstall

For a first-time setup on a new machine, follow
[tutorials/getting-started.md](../tutorials/getting-started.md) instead — it
covers the dependencies too. This page assumes the tools are already present.

## Preview what would change

```bash
./install.sh --dry-run
```

Prints every link and backup it would make and writes nothing.

## Install

```bash
./install.sh
exec zsh
```

The script is idempotent — running it again reports `ok:` for everything
already in place. Anything already at a destination is moved to
`~/.dotfiles-backup/<timestamp>/` before the link is made; nothing is
overwritten.

## Update

Because the configuration is symlinked, edits in the repo take effect in the
next shell.

```bash
git pull
exec zsh
```

Run `./install.sh` again only if the pull added a new file — the script's `MAP`
array will have grown.

## Uninstall

```bash
./install.sh --unlink
```

Removes only symlinks that point into this repository; anything else at those
paths is left alone.

Backups are not restored automatically. To put one back:

```bash
ls ~/.dotfiles-backup/
cp -R ~/.dotfiles-backup/<timestamp>/.zshenv ~/.zshenv
```

Shell history, in `~/.local/state/zsh/history`, is not touched by either
direction.

## Install to a different location

The script resolves paths from its own location, so the repository can live
anywhere:

```bash
git clone git@github.com:subidit/dotfiles.git ~/somewhere/else
cd ~/somewhere/else && ./install.sh
```

It also honours `XDG_CONFIG_HOME`, `XDG_CACHE_HOME` and `XDG_STATE_HOME` if you
have set them to something non-default.
