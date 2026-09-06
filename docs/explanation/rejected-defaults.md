# Defaults that were rejected

Settings that are common in zsh configurations, or were present in an earlier
version of this one, and are deliberately absent. Written down so they do not
get quietly re-added.

## `alias grep='rg'`

**Removed. This one produces wrong answers.**

`ripgrep` is excellent and it is not a `grep`. By default it skips hidden files
and anything matched by `.gitignore`. Aliased over `grep`, that means:

```
grep -r "TOKEN" .        # reports nothing
rg --no-ignore --hidden "TOKEN" .   # finds it in .env
```

A search tool that silently reports "no matches" for files that do contain the
pattern is worse than no search tool, because you believe it. The failure is
invisible at the call site and only shows up as a wrong conclusion later.

`rg` is also two characters shorter than `grep`, so the alias was not even
saving typing. `grep` is now `grep --color=auto`, and `rg` is `rg`.

## `setopt NO_CASE_MATCH`

**Removed.** It reads like a companion to `NO_CASE_GLOB`, and it is not.

`NO_CASE_GLOB` affects filename globbing — usually what you want on macOS,
whose filesystem is case-insensitive anyway. `NO_CASE_MATCH` changes the
semantics of `[[ ... == pattern ]]` and `case` for *everything loaded
afterwards*, including plugins and completion functions. A `case` statement in
someone else's code that meant to distinguish `-v` from `-V` stops doing so.

The blast radius is the whole shell and the failures are silent. `NO_CASE_GLOB`
is kept; this is not.

## `setopt MENU_COMPLETE`

**Removed**, because it contradicts `AUTO_MENU`, which is kept.

`AUTO_MENU` opens a selection menu on a second Tab. `MENU_COMPLETE` inserts the
first match immediately on the first Tab. With both set, the second never gets
a chance to happen — you get a guess inserted into your command line instead of
a menu. Keeping both is a common copy-paste artefact.

## `INC_APPEND_HISTORY` alongside `SHARE_HISTORY`

**Removed as redundant.** `SHARE_HISTORY` implies incremental appending. Setting
both is harmless but suggests the interaction was not understood.

## `HISTSIZE` equal to `SAVEHIST`

**Changed.** They were both 50000.

Deduplication happens in the in-memory list, so `HISTSIZE` needs headroom above
`SAVEHIST` for `HIST_EXPIRE_DUPS_FIRST` to have anything to work with. Now
200000 in memory against 100000 on disk.

## `setopt CORRECT`

**Kept**, with reservations. It offers to fix mistyped command names.

It is noisy around commands that legitimately do not exist yet, and it has
opinions about arguments that resemble commands. It is kept because the
correction prompt is easy to decline and the saved retypes outweigh it — but it
is the setting in this file most likely to be worth removing, and
`CORRECT_ALL`, which extends the behaviour to every argument, is definitely not
enabled.

## `unsetopt PROMPT_SP`

**Kept**, as a real trade with a real cost.

`PROMPT_SP` preserves output that did not end in a newline, marking it with an
inverse `%`. Disabling it removes the marker and the blank line before the
prompt — and means a command whose output lacks a trailing newline gets its
last line partly overwritten by the prompt.

Cleaner prompt, occasionally lost output. Worth knowing about if a line ever
looks truncated.

## `setopt GLOB_DOTS`

**Kept**, with a guard.

It makes globs match dotfiles without a literal leading dot — consistent with
this configuration's general stance that hidden files should not be invisible.
It also means `rm *` is considerably wider than it looks. `RM_STAR_WAIT` is set
alongside it, which forces a pause before `rm *` executes.
