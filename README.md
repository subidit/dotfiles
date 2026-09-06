# dotfiles

A zsh configuration for macOS built around two commitments: `$HOME` stays clean,
and the terminal renders one colour system rather than four.

No framework, no plugin manager. Starts in about 50 ms.

```bash
git clone https://github.com/subidit/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
brew bundle install --file=Brewfile
./install.sh --dry-run    # look first
./install.sh
exec zsh
```

Full walk-through: [Setting up on a new Mac](docs/tutorials/getting-started.md).

---

## The two ideas

### `$HOME` is an interface

Tools scatter dotfiles across the home directory until `ls -a ~` returns fifty
entries, five of which you chose. This configuration exiles everything that can
be exiled into the XDG base directories, and the variables live in `.zshenv` so
non-interactive scripts obey them too.

What is left: `.DS_Store`, `.Trash`, `.cache`, `.claude`, `.claude.json`,
`.config`, `.local`, `.zshenv`. Three hidden directories instead of fifty
hidden files.

A distinction that is easy to get wrong: shell history is *state*, not config.
It is generated, machine-specific and often sensitive, so it lives in
`~/.local/state/`, not next to the rc files where you might push it to a public
repository.

→ [XDG and a clean `$HOME`](docs/explanation/xdg-and-a-clean-home.md)

### One colour system

A terminal accumulates palettes — the ANSI 16 from the theme, whatever `eza` was
told, whatever `fzf` defaults to, whatever the syntax highlighter ships. Each is
fine alone; together they mean the same idea arrives in a different colour
depending on which program drew it.

Here a table of 46 colours is declared once, in `.zshrc`, and everything is
derived from it: `eza`, `LS_COLORS`, the completion menu, `fzf`, syntax
highlighting, autosuggestions. Adding a colour means adding a row.

Every colour is solved in OKLCH against the terminal's actual background and
measured with APCA contrast:

- **Lightness carries hierarchy.** Five tiers, `Lc` 78 / 62 / 48 / 34 / 26.
  Nothing readable sits below `Lc 30`.
- **Hue carries category, never rank.**
- **Ordered scales hold lightness constant.** File size is ordinal, but every
  step is a number you must read — so a lightness ramp would make small files
  less legible than large ones. Lightness is pinned at `Lc 60` across all five
  steps and the ordering goes into hue and chroma instead.

`tools/palette-report.py --check` fails the build if any colour drops below the
floor. Running it against the palette this replaced found punctuation at
`Lc 0.0` — not dim, not rendering.

→ [The colour model](docs/explanation/colour-model.md) ·
  [all 46 colours, measured](docs/reference/palette.md)

---

## Features

**Colour**
- 46-colour palette, single source of truth, six consumers derived from it
- 24-bit in Ghostty, automatically quantised to the xterm-256 cube over `ssh`
- Permission bits coloured by *which* bit (read cyan, write amber, execute
  green) so `rwxr-xr-x` forms scannable vertical bands; unset bits are
  achromatic, so saturation itself means "this bit is on"
- File sizes on an iso-lightness scale, with the unit suffix set one tier below
  the number so `4.3` reads before `MB`
- Git status, ownership, and dates each on their own measured tier
- `LS_COLORS` generated too, so a directory is the same blue in `ls` and in the
  Tab menu — it was previously unset, silently leaving the completion menu
  colourless

**Completion**
- Case-insensitive, substring, and partial matching
- Menu selection with `hjkl` navigation, grouped by type
- `compinit` cache rebuilt only when stale, checked with a glob qualifier
  rather than on every start
- Completion results cached under `$XDG_CACHE_HOME`

**History**
- 200 000 in memory, 100 000 on disk, deduplicated
- Timestamps and durations recorded, shared live between shells
- Prefix search on `↑`/`↓` that parks the cursor at end of line
- `^R` fuzzy search across everything

**Navigation**
- `zoxide` for frecency-ranked jumps, `fzf` for `^T` / `^R` / `alt-C` / `**<Tab>`
- Every `cd` pushes the directory stack; `d` lists it, `cd -<Tab>` jumps
- `AUTO_CD`, `..`, `...`
- Word motions stop at path separators instead of swallowing whole paths

**Editing**
- `^X^E` opens the current line in `$EDITOR`
- `^U` kills to start of line rather than discarding the whole line
- alt/ctrl arrows for word movement, both encodings bound

**Listing**
- `eza` with icons and git status; ISO timestamps for a straight column edge
- `--smart-group` drops the group column when it duplicates the owner
- `--color-scale-mode=fixed`, without which the designed size colours are
  ignored in favour of RGB interpolation

**Deliberate omissions** — `grep` is not aliased to `rg` (it skips hidden and
gitignored files, so the alias produces silent false negatives),
`NO_CASE_MATCH` is not set, `MENU_COMPLETE` is not set.
→ [Defaults that were rejected](docs/explanation/rejected-defaults.md)

---

## What is here

```
home/.zshenv          bootstrap: XDG roots, ZDOTDIR, dotfile exile
config/zsh/           .zshrc, .zprofile, .p10k.zsh
config/ghostty/       font and size
config/ripgrep/       search defaults matching the fd flags
install.sh            idempotent symlinks, --dry-run and --unlink
Brewfile              every dependency
tools/                palette measurement and contrast gate
docs/                 Diátaxis-organised documentation
```

## Documentation

Organised on [Diátaxis](https://diataxis.fr) — [docs/](docs/) is the index.

| | Practical | Theoretical |
|---|---|---|
| **Study** | [Tutorial](docs/tutorials/getting-started.md) | [Explanation](docs/explanation/design-principles.md) |
| **Work** | [How-to](docs/README.md#how-to-guides) | [Reference](docs/README.md#reference) |

## Requirements

macOS, Homebrew, Ghostty. The palette is measured against Ghostty's `#282c34`
default background — it works elsewhere, but the contrast figures are only true
there.

## Licence

MIT. Take what is useful.
