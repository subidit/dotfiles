# Shell options

Every `setopt` / `unsetopt` in [`config/zsh/.zshrc`](../../config/zsh/.zshrc),
with what it does. Options deliberately *not* set are in
[explanation/rejected-defaults.md](../explanation/rejected-defaults.md).

## Navigation and globbing

| Option | Effect |
|---|---|
| `AUTO_CD` | A bare directory name is a `cd`. `src` instead of `cd src`. |
| `AUTO_PARAM_SLASH` | Completing a directory appends `/`, so you can keep typing. |
| `EXTENDED_GLOB` | Enables `^`, `~`, `#` glob operators and glob qualifiers. Required by the `compinit` cache check. |
| `GLOB_DOTS` | Globs match dotfiles without a literal leading dot. |
| `NO_CASE_GLOB` | Case-insensitive globbing. |
| `RM_STAR_WAIT` | Forces a pause before `rm *` runs. Present because `GLOB_DOTS` widens what `*` means. |

## Directory stack

| Option | Effect |
|---|---|
| `AUTO_PUSHD` | Every `cd` pushes onto the stack. |
| `PUSHD_IGNORE_DUPS` | No duplicate entries. |
| `PUSHD_SILENT` | Do not print the stack on every `cd`. |
| `PUSHD_TO_HOME` | Bare `pushd` goes to `~`. |

`DIRSTACKSIZE=20`. List the stack with `d`; jump with `cd -<Tab>`.

## History

| Option | Effect |
|---|---|
| `EXTENDED_HISTORY` | Records timestamp and duration per entry. |
| `HIST_IGNORE_DUPS` | Skip an entry identical to the one before it. |
| `HIST_IGNORE_ALL_DUPS` | Remove older duplicates of a repeated command. |
| `HIST_SAVE_NO_DUPS` | Do not write duplicates to the file. |
| `HIST_FIND_NO_DUPS` | Do not show duplicates while searching. |
| `HIST_EXPIRE_DUPS_FIRST` | Drop duplicates before unique entries when trimming. |
| `HIST_IGNORE_SPACE` | A leading space keeps a command out of history. |
| `HIST_REDUCE_BLANKS` | Normalise whitespace before storing. |
| `HIST_VERIFY` | Expand `!!` onto the line for review instead of running it. |
| `SHARE_HISTORY` | Share live between concurrent shells. Implies `INC_APPEND_HISTORY`. |

`HISTSIZE=200000` in memory, `SAVEHIST=100000` on disk. The in-memory figure is
deliberately larger — deduplication works on the in-memory list.

File: `$XDG_STATE_HOME/zsh/history`.

## Completion

| Option | Effect |
|---|---|
| `AUTO_MENU` | A second Tab opens the selection menu. |
| `COMPLETE_IN_WORD` | Complete from the cursor, not only at end of word. |
| `ALWAYS_TO_END` | Move the cursor to the end after completing. |

## Interface

| Option | Effect |
|---|---|
| `INTERACTIVE_COMMENTS` | `#` starts a comment on an interactive line. |
| `CORRECT` | Offers corrections for mistyped command names. |
| `NO_BEEP` | Silence. |
| `unsetopt PROMPT_SP` | Removes the inverse-`%` marker and blank line before the prompt. Trades away preservation of output lacking a trailing newline. |
