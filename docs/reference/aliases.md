# Aliases and functions

Defined in [`config/zsh/.zshrc`](../../config/zsh/.zshrc).

## Listing

All five share `--color=always --icons=always --group-directories-first`.

| Alias | Expands to | Purpose |
|---|---|---|
| `ls` | `eza` + shared flags | Plain listing |
| `ll` | `ls` + `-l --git --smart-group --time-style=long-iso --color-scale=size --color-scale-mode=fixed` | Long listing |
| `la` | as `ll`, plus `-a` | Long listing including dotfiles |
| `lt` | `--tree --level=2 --git-ignore` | Tree, two levels |
| `lta` | `--tree --git-ignore` | Tree, unlimited depth |

Two flags carry weight:

- `--color-scale-mode=fixed` is what makes the five designed size colours
  apply. The default, `gradient`, interpolates in RGB and ignores the
  `nb`/`nk`/`nm`/`ng`/`nt` codes entirely.
- `--smart-group` hides the group column when it duplicates the owner.

## Replacements

| Alias | Expands to | Note |
|---|---|---|
| `cat` | `bat --paging=never --style=plain` | `--style=plain` keeps line numbers and the header out, so output stays copy-pasteable and diffable. Run `bat` directly for the full presentation. |
| `grep` | `grep --color=auto` | Real `grep`. `rg` is **not** aliased over it — see [rejected-defaults](../explanation/rejected-defaults.md#alias-greprg). |

## Navigation

| Alias | Expands to |
|---|---|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `d` | `dirs -v` — the numbered directory stack |

Combine `d` with `cd -<Tab>` to jump to any recent directory.

## From zoxide

| Command | Behaviour |
|---|---|
| `z <term>` | Jump to the best-matching directory you have visited |
| `zi` | Pick interactively through fzf |

## Internal functions

| Name | Purpose |
|---|---|
| `_fzf_compgen_path` | Makes `**<Tab>` use `fd` — fast and gitignore-aware |
| `_fzf_compgen_dir` | The same for commands that take only directories (`cd`, `pushd`, `rmdir`) |
