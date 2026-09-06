# XDG and a clean `$HOME`

Why the configuration goes to some trouble to keep hidden files out of the home
directory, and what the limits of that are.

## The problem

Unix tools have historically written their state to `~/.toolname`. With enough
tools installed, `ls -a ~` returns fifty entries, of which perhaps five are
things you chose. Backup, sync and inspection all get harder, and the signal —
*which of these do I actually care about?* — is gone.

## The specification

The XDG Base Directory Specification defines four roots:

| Variable | Default | Holds |
|---|---|---|
| `XDG_CONFIG_HOME` | `~/.config` | configuration you would version |
| `XDG_CACHE_HOME` | `~/.cache` | regenerable; safe to delete |
| `XDG_DATA_HOME` | `~/.local/share` | durable data you would miss |
| `XDG_STATE_HOME` | `~/.local/state` | logs, history, "where was I" |

Three hidden directories replace fifty hidden files. That is the whole trade.

## The distinction that is easy to get wrong

Config and state look similar and are not. **Config** is what you wrote and
would commit; **state** is what the program accumulated.

Shell history is the clearest case. It is generated, machine-specific, often
sensitive, and you would never commit it — so it belongs in `XDG_STATE_HOME`,
not next to the rc files. The setup this replaced kept `.zsh_history` inside
`~/.config/zsh/`, which put a private, unversionable file inside the directory
you would most want to push to a public repository.

## Three ways a tool can behave

**It honours XDG natively.** Nothing to do. `git` reads
`$XDG_CONFIG_HOME/git/config`, `bat` and `fresh` use `$XDG_CONFIG_HOME`
directly, `zoxide` uses `$XDG_DATA_HOME`.

Note `git` only does this if `~/.gitconfig` does not exist — a stray file in
`$HOME` silently wins.

**It can be told.** Most of the rest. An environment variable moves it, and
these live in [`home/.zshenv`](../../home/.zshenv) so that non-interactive
scripts obey them too — a script that shells out to `npm` should write to the
same cache an interactive shell would.

**It cannot be moved.** `~/.ssh` and `~/.Trash` are fixed. `.DS_Store` is
written by Finder with no local opt-out. These are accepted.

## Why `.zshenv` and not `.zshrc`

`~/.zshenv` is the one file zsh will read from `$HOME` regardless of `$ZDOTDIR`,
so it is the bootstrap: it sets the XDG variables, points `ZDOTDIR` at
`~/.config/zsh`, and everything else follows from there.

It is also sourced by *every* zsh, including non-interactive ones. That is
exactly why the exile variables belong there rather than in `.zshrc` — but it is
also why it must stay declarative. No logic, no output, no command
substitution: anything slow or noisy in `.zshenv` is paid on every script
invocation, and anything that prints will corrupt tools that parse a
subshell's output.

## Where this lands

After setup, `ls -A ~` shows: `.DS_Store`, `.Trash`, `.cache`, `.claude`,
`.claude.json`, `.config`, `.local`, `.zshenv`.

Eight entries, six of them structural. See
[how-to/keep-home-clean.md](../how-to/keep-home-clean.md) for adding a new tool
to the exile list, and [reference/environment.md](../reference/environment.md)
for the full variable list.
