# Terminal keyboard shortcuts

Every keyboard shortcut available in a Ghostty window set up by [the fresh Mac tutorial](../tutorials/fresh-mac.md), grouped by the kind of work, with where each one comes from.

Versions: zsh 5.9 (emacs keymap), Ghostty 1.3.1, fzf 0.74.5, zsh-autosuggestions 0.7.1, micro 2.0.15, less 668.

## Notation

| Written | Key |
|---|---|
| Ctrl-X | Control and X |
| Alt-X | left Option and X (Ghostty's `macos-option-as-alt = left`). Esc then X does the same. |
| ⌘X | Command and X |
| Ctrl-X Ctrl-E | Ctrl-X, released, then Ctrl-E |
| Home, End | fn-← and fn-→ on a Mac keyboard |
| Delete | fn-Backspace on a Mac keyboard |

## Sources

| Source | Meaning |
|---|---|
| **zsh** | Default binding of zsh's line editor (ZLE), emacs keymap |
| **zsh completion** | Added by zsh's completion system when `compinit` runs |
| **tty** | macOS terminal driver (`stty`); works in every program, not only zsh |
| **.zshrc** | A line in the tutorial's `.zshrc` block (step 5) |
| **.zshrc (extra)** | A line in the author's `.zshrc` that is not in the tutorial; the line is given in [Extra bindings](#extra-bindings) |
| **fzf** | fzf's shell integration, `source <(fzf --zsh)` |
| **autosuggestions** | zsh-autosuggestions |
| **Ghostty** | Ghostty's default keybinding |
| **macOS** | Mac keyboard behaviour |

Where a key is replaced, the **Replaces** column names what it did before.

---

## Moving the cursor

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Ctrl-A, Home | Start of line | zsh; Home: .zshrc | |
| Ctrl-E, End | End of line | zsh; End: .zshrc | |
| ⌘← / ⌘→ | Start / end of line (Ghostty sends Ctrl-A / Ctrl-E) | Ghostty | |
| Ctrl-B / Ctrl-F, ← / → | Back / forward one character | zsh | |
| Alt-B / Alt-F | Back / forward one word | zsh | |
| Alt-← / Alt-→ | Back / forward one word (Ghostty sends Alt-B / Alt-F) | Ghostty; .zshrc for other terminals | |
| Alt-< / Alt-> | First / last line of history | zsh | |
| Ctrl-X Ctrl-X | Swap cursor and mark | zsh | |
| Ctrl-Space | Set the mark. macOS uses Ctrl-Space to switch input sources when more than one is enabled; then it never reaches zsh | zsh | |

A word ends at `/` and `=` with the author's `WORDCHARS` (see [Extra bindings](#extra-bindings)); with zsh's default, `/` and `=` are part of a word.

## Deleting and pasting back

Deleted words and lines go to zsh's kill ring, separate from the macOS clipboard.

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Backspace, Ctrl-H | Delete character before cursor | zsh | |
| Ctrl-D | Delete character under cursor; on an empty line, exit the shell; at the end of the line, list completions | zsh | |
| Ctrl-W, Alt-Backspace | Delete word before cursor | zsh | |
| Alt-D | Delete word after cursor | zsh | |
| Ctrl-U | Delete from cursor to start of line | .zshrc (extra) | delete whole line (zsh) |
| ⌘Backspace | Same as Ctrl-U (Ghostty sends Ctrl-U) | Ghostty | |
| Ctrl-K | Delete from cursor to end of line | zsh | |
| Ctrl-X Ctrl-K | Delete the whole line (all lines, for a multi-line command) | zsh | |
| Ctrl-Y | Paste back the last deleted text | zsh | |
| Alt-Y | Right after Ctrl-Y: cycle to older deleted text | zsh | |
| Alt-W | Copy cursor-to-mark into the kill ring | zsh | |

## Changing text

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Alt-U / Alt-L | Uppercase / lowercase the word after the cursor | zsh | |
| Alt-T | Swap the two words around the cursor | zsh | |
| Ctrl-_, Ctrl-X Ctrl-U | Undo | zsh | |
| Alt-' | Quote the whole line | zsh | |
| Ctrl-X Ctrl-O | Toggle overwrite mode | zsh | |
| Ctrl-V *key* | Insert the next key literally; shows the sequence a key sends | zsh | |
| Ctrl-X Ctrl-E | Open the line in `$EDITOR` (micro); saving and quitting puts the edited text back on the line, not run | .zshrc | |

## Running and controlling commands

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Enter, Ctrl-M, Ctrl-J | Run the line | zsh | |
| Ctrl-C | Interrupt the running program; on the prompt, discard the line | tty | |
| Ctrl-Z | Suspend the running program (`fg` resumes it) | tty | |
| Ctrl-\ | Quit the running program (stronger than Ctrl-C) | tty | |
| Ctrl-D | In a program reading input: end of input | tty | |
| Ctrl-S / Ctrl-Q | Freeze / resume terminal output | tty | zsh's own Ctrl-S and Ctrl-Q never reach the line editor |
| Ctrl-L | Clear the screen, keep the line | zsh | |
| ⌘K | Clear the screen and scrollback | Ghostty | |
| Alt-Q | Put the line aside, run another command, then get the line back | zsh | |
| Alt-G | Get back a line put aside with Alt-Q | zsh | |
| Alt-A | Run the line and keep it on the next prompt | zsh | |
| Ctrl-O | Run the line and load the next one from history | zsh | |
| Ctrl-G | Cancel the current editing action (search, prefix) | zsh | |

## History

| Keys | Action | Source | Replaces |
|---|---|---|---|
| ↑ / ↓ | Previous / next command starting with the text before the cursor; cursor at end of line. With an empty line: every command | .zshrc (extra) | plain previous / next line (zsh) |
| Ctrl-P / Ctrl-N | Previous / next history line | zsh | |
| Alt-P / Alt-N | Previous / next command starting with the first word typed | zsh | |
| Ctrl-R | fzf list of all history; typing filters it; Enter puts the choice on the line | fzf | incremental search (zsh) |
| Alt-. , Alt-_ | Insert the last word of the previous command; repeat for older commands | zsh | |

Inside the Ctrl-R list:

| Keys | Action | Source |
|---|---|---|
| Ctrl-R | Toggle sorting by recency vs. match score | fzf |
| Alt-R | Toggle raw mode (show non-matching lines too) | fzf |
| Tab / Shift-Tab | Mark several commands | fzf |

## Suggestions

The grey text after the cursor is a suggestion from history.

| Keys | Action | Source |
|---|---|---|
| →, End, Ctrl-E, Ctrl-F | Accept the whole suggestion | autosuggestions (End: .zshrc) |
| Alt-F, Alt-→ | Accept the next word of the suggestion | autosuggestions (Alt-→: Ghostty) |

## Completion

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Tab | Complete; with `**` before the cursor, fzf list instead | fzf | complete (zsh) |
| *path*`**` Tab | fzf list of files and folders under *path* (`cd **` Tab: folders only) | fzf | |
| Ctrl-D | List possible completions | zsh | |
| Ctrl-X h | Show what the completion system would try here | zsh completion | |
| Ctrl-X a | Expand an alias | zsh completion | |
| Ctrl-X e, Ctrl-X * | Expand the word (globs, variables) | zsh completion; zsh | |
| Ctrl-X m | Complete the most recently modified file | zsh completion | |
| Alt-/ / Alt-, | Complete a word from older / newer history | zsh completion | |

In the completion menu (after a second Tab):

| Keys | Action | Source |
|---|---|---|
| Tab / Shift-Tab | Next / previous match | zsh completion; Shift-Tab: .zshrc (extra) |
| Arrows | Move through the grid | zsh completion |
| Enter | Accept the match and close the menu | zsh completion |
| Ctrl-G, Ctrl-C | Close the menu without accepting | zsh |

## Files and folders

| Keys | Action | Source | Replaces |
|---|---|---|---|
| Ctrl-T | fzf list of files and folders below here, `.gitignore`'d ones skipped, with preview; Enter pastes the path(s) at the cursor | fzf (settings: .zshrc) | swap two characters (zsh) |
| Alt-C | fzf list of folders below here, with preview; Enter changes into it | fzf (settings: .zshrc) | capitalize word (zsh) |

## Inside any fzf list

| Keys | Action | Source |
|---|---|---|
| Typing | Filter the list | fzf |
| ↑ / ↓, Ctrl-K / Ctrl-J, Ctrl-P / Ctrl-N | Move | fzf |
| Page Up / Page Down | Move a page | fzf |
| Tab / Shift-Tab | Mark and move down / up (lists that allow several picks) | fzf |
| Enter | Accept | fzf |
| Esc, Ctrl-C, Ctrl-G, Ctrl-Q | Close without picking | fzf |
| Ctrl-U | Clear the filter text | fzf |
| Alt-Backspace | Delete a word of the filter | fzf |
| Shift-↑ / Shift-↓ | Scroll the preview | fzf |
| Ctrl-/, Alt-/ | Toggle word wrap | fzf |
| Ctrl-Z | Ignored (the list can't be suspended) | fzf |

## Help

| Keys | Action | Source |
|---|---|---|
| Alt-H | Open the man page for the command on the line; the line comes back after | zsh |
| Alt-? | Show what the first word on the line is (alias, function, command) | zsh |
| Ctrl-X = | Show the character under the cursor and its position | zsh |

## Ghostty window

### Tabs, windows and splits

| Keys | Action | Source |
|---|---|---|
| ⌘T | New tab | Ghostty |
| ⌘N | New window | Ghostty |
| ⌘W | Close the tab or split | Ghostty |
| ⌘⇧W | Close the window | Ghostty |
| ⌘1 … ⌘8 | Go to tab 1–8 | Ghostty |
| ⌘9 | Go to the last tab | Ghostty |
| ⌘⇧] / ⌘⇧[, Ctrl-Tab / Ctrl-⇧-Tab | Next / previous tab | Ghostty |
| ⌘D / ⌘⇧D | Split right / down | Ghostty |
| ⌘] / ⌘[ | Next / previous split | Ghostty |
| ⌘⌥ + arrow | Go to the split in that direction | Ghostty |
| ⌘Ctrl + arrow | Resize the split | Ghostty |
| ⌘Ctrl-= | Make splits equal | Ghostty |
| ⌘⇧Enter | Zoom the split | Ghostty |
| ⌘Enter, ⌘Ctrl-F | Full screen | Ghostty |
| ⌘Q | Quit Ghostty | Ghostty |

### Scrollback, search and selection

| Keys | Action | Source |
|---|---|---|
| ⌘↑ / ⌘↓ | Jump to the previous / next prompt | Ghostty |
| ⌘Page Up / ⌘Page Down | Scroll a page | Ghostty |
| ⌘Home / ⌘End | Scroll to top / bottom | Ghostty |
| ⌘F | Search the scrollback | Ghostty |
| ⌘G / ⌘⇧G | Next / previous search match | Ghostty |
| Esc, ⌘⇧F | End search | Ghostty |
| ⌘E | Search for the selected text | Ghostty |
| ⌘J | Scroll to the selection | Ghostty |
| Shift + arrow, Shift-Home/End, Shift-Page Up/Down | Extend the selection | Ghostty |
| ⌘A | Select all | Ghostty |
| ⌘C / ⌘V | Copy / paste | Ghostty |
| ⌘⇧V | Paste the selection | Ghostty |
| ⌘⇧J | Paste the screen contents as a file path | Ghostty |
| ⌘⇧⌥J | Open the screen contents in a text file | Ghostty |

### Appearance and config

| Keys | Action | Source |
|---|---|---|
| ⌘= / ⌘- / ⌘0 | Bigger / smaller / reset font | Ghostty |
| ⌘, | Open the config file | Ghostty |
| ⌘⇧, | Reload the config | Ghostty |
| ⌘⇧P | Command palette | Ghostty |
| ⌘⌥I | Inspector | Ghostty |
| ⌘Z / ⌘⇧Z | Undo / redo closing a tab or split | Ghostty |

## Pager: `man`, `bat`, `git log`

These open in less (`man` through bat, set by `MANPAGER` in the author's `.zshrc`).

| Keys | Action | Source |
|---|---|---|
| Space, Page Down / b, Page Up | Page down / up | less |
| ↓ / ↑, j / k | Line down / up | less |
| g / G | Top / bottom | less |
| /*text* Enter, ?*text* Enter | Search forward / backward | less |
| n / N | Next / previous match | less |
| h | Help | less |
| q | Quit | less |

## Editor: micro

Opened by `m`, `fe`, Ctrl-X Ctrl-E, git and gh.

| Keys | Action | Source |
|---|---|---|
| Ctrl-S | Save | micro |
| Ctrl-Q | Quit (asks to save if changed) | micro |
| Ctrl-Z / Ctrl-Y | Undo / redo | micro |
| Ctrl-C / Ctrl-X / Ctrl-V | Copy / cut / paste | micro |
| Ctrl-A | Select all | micro |
| Ctrl-K | Cut the line | micro |
| Ctrl-D | Duplicate the line | micro |
| Ctrl-F | Find | micro |
| Ctrl-N / Ctrl-P | Next / previous match | micro |
| Ctrl-L | Go to line | micro |
| Ctrl-O | Open a file | micro |
| Ctrl-T | New tab | micro |
| Ctrl-E | Command bar | micro |
| Ctrl-G | Help | micro |

Custom bindings go in `~/.config/micro/bindings.json` (empty in this setup).

## Not bound

| Keys | Behaviour |
|---|---|
| Delete (fn-Backspace) | Does nothing in zsh: Ghostty sends `^[[3~`, which zsh's emacs keymap leaves unbound |
| Right Option + key | Types a special character (ç, ∫, …), not Alt |

## Extra bindings

Lines in the author's `.zshrc` that are not in the tutorial, for the rows marked **.zshrc (extra)**:

```zsh
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'   # words end at / and =
bindkey '^U' backward-kill-line
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
zmodload zsh/complist
zstyle ':completion:*' menu select
bindkey -M menuselect '^[[Z' reverse-menu-complete
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

To list every binding in the current shell: `bindkey` (main keymap), `bindkey -M menuselect`, and `ghostty +list-keybinds` for Ghostty.
