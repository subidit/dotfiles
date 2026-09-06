# How to keep a new tool out of `$HOME`

You installed something and it created `~/.newtool`. Here is the sequence for
getting rid of it.

For why any of this matters, see
[explanation/xdg-and-a-clean-home.md](../explanation/xdg-and-a-clean-home.md).

## 1. Check whether it already supports XDG

Often it does and simply lost a race with an existing file:

```bash
man newtool | grep -iE 'XDG|config file|\.config'
```

If the tool reads `$XDG_CONFIG_HOME/newtool/` but you have `~/.newtool`, the
legacy path usually wins. Move the file and the tool finds the new location.

## 2. Look for an environment variable

The common spellings are `NEWTOOL_HOME`, `NEWTOOL_CONFIG`, `NEWTOOL_CONFIG_DIR`,
`NEWTOOL_DATA_DIR` and `NEWTOOL_CACHE_DIR`.

```bash
newtool --help | grep -iE 'home|config|cache|data|history'
env | grep -i newtool
```

The [XDG ninja](https://github.com/b3nj5m1n/xdg-ninja) project is a good
reference for tools that need a specific incantation.

## 3. Add it to `.zshenv`

Pick the right root — see the table in
[reference/environment.md](../reference/environment.md#xdg-base-directories).
Config you would version, state you would not, cache you could delete.

```bash
# home/.zshenv, in the exile block
export NEWTOOL_CONFIG_DIR="$XDG_CONFIG_HOME/newtool"
export NEWTOOL_HISTORY="$XDG_STATE_HOME/newtool/history"
```

It goes in `.zshenv`, not `.zshrc`, so that scripts and non-interactive shells
obey it too.

## 4. Create the directory if the tool will not

Most tools create a missing config directory; some fail silently instead. If the
tool needs it to exist, add it to the loop near the end of
[`install.sh`](../../install.sh):

```bash
for d in "$XDG_STATE_HOME/zsh" … "$XDG_STATE_HOME/newtool"; do
```

## 5. Migrate what is already there and verify

```bash
mkdir -p "$XDG_CONFIG_HOME/newtool"
mv ~/.newtool/* "$XDG_CONFIG_HOME/newtool/"
rmdir ~/.newtool

exec zsh
newtool --version    # confirm it still finds its config
ls -A ~ | grep newtool   # should print nothing
```

## When a tool cannot be moved

Some cannot: `~/.ssh` is fixed by convention and by permission checks, and
`.DS_Store` is written by Finder with no local opt-out. Leave them.

If the variable exists but relocating would break a running program — moving
`~/.claude` mid-session, say — do it when nothing is using it.

## Audit

```bash
ls -A ~ | grep '^\.'
```

The expected set after setup is `.DS_Store`, `.Trash`, `.cache`, `.claude`,
`.claude.json`, `.config`, `.local`, `.zshenv`. Anything else is a new arrival
worth chasing.
