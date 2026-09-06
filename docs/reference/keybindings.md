# Key bindings

Emacs-style bindings (zsh's default mode). Set in
[`config/zsh/.zshrc`](../../config/zsh/.zshrc).

## History

| Key | Widget | Behaviour |
|---|---|---|
| `↑` | `history-beginning-search-backward-end` | Search backward for entries starting with what you have typed |
| `↓` | `history-beginning-search-forward-end` | The same, forward |
| `^P` / `^N` | as above | Same behaviour without leaving the home row |
| `^R` | `fzf-history-widget` | Fuzzy search all history (from fzf) |

The `-end` suffix matters: the plain widgets leave the cursor where it was,
which reads as a glitch mid-recall. These park it at end of line.

## Movement

| Key | Widget |
|---|---|
| `Home` / `End` | `beginning-of-line` / `end-of-line` |
| `alt` + `←` / `→` | `backward-word` / `forward-word` |
| `ctrl` + `←` / `→` | `backward-word` / `forward-word` |

Both modifier sets are bound because terminals disagree about which they send.

`WORDCHARS='*?_-.[]~&;!#$%^(){}<>'` — note the absence of `/` and `=`, so word
motions stop at path separators. The zsh default swallows an entire path as one
word.

## Editing

| Key | Widget | Note |
|---|---|---|
| `Delete` | `delete-char` | |
| `alt` + `Backspace` | `backward-kill-word` | |
| `^U` | `backward-kill-line` | Kills to start of line, not the whole line — zsh's default `kill-whole-line` discards text ahead of the cursor too |
| `^X^E` | `edit-command-line` | Opens the current line in `$EDITOR`; save and quit to run it |

## Completion menu

Active only while the menu is open.

| Key | Action |
|---|---|
| `h` `j` `k` `l` | Move left / down / up / right |
| `Enter` | Accept |
| `^C` / `Esc` | Cancel |

## From fzf

| Key | Action |
|---|---|
| `^T` | Insert a file path, with a `bat` preview |
| `^R` | Search command history |
| `alt` + `C` | `cd` into a subdirectory |

## From zsh-autosuggestions

| Key | Action |
|---|---|
| `→` / `^F` | Accept the whole suggestion |
| `alt` + `→` | Accept one word |
