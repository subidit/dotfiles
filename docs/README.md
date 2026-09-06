# Documentation

Organised on the [Diátaxis](https://diataxis.fr) model. The four sections
answer different questions, and mixing them makes all four worse — so a page
that explains *why* will not also walk you through *how*, and vice versa. It
will link to its counterpart instead.

| | Practical | Theoretical |
|---|---|---|
| **Study** | [Tutorials](#tutorials) — learning | [Explanation](#explanation) — understanding |
| **Work** | [How-to](#how-to-guides) — a goal | [Reference](#reference) — facts |

## Tutorials

*New here? Start with this.* A guaranteed path from nothing to a working setup.

- [Setting up on a new Mac](tutorials/getting-started.md)

## How-to guides

*You know what you want to do.* Recipes for specific goals.

- [Install, update and uninstall](how-to/install.md)
- [Keep a new tool out of `$HOME`](how-to/keep-home-clean.md)
- [Change a colour](how-to/retune-the-palette.md)
- [Adjust typography](how-to/adjust-typography.md)
- [Change the prompt](how-to/customise-the-prompt.md)
- [Troubleshooting](how-to/troubleshoot.md)

## Reference

*You need a specific fact.* Dry and complete.

- [File layout](reference/file-layout.md) — repo and installed paths, load order
- [Environment variables](reference/environment.md) — every variable and why
- [Shell options](reference/shell-options.md) — every `setopt`
- [Key bindings](reference/keybindings.md)
- [Aliases and functions](reference/aliases.md)
- [Completion](reference/completion.md) — caching, matching, colour
- [Palette](reference/palette.md) — all 46 colours, measured *(generated)*
- [Tools](reference/tools.md) — the dependencies and their roles

## Explanation

*You want to know why.* Background, trade-offs, roads not taken.

- [Design principles](explanation/design-principles.md) — start here
- [XDG and a clean `$HOME`](explanation/xdg-and-a-clean-home.md)
- [The colour model](explanation/colour-model.md) — APCA, OKLCH, and why
- [Typography](explanation/typography.md)
- [Why no framework](explanation/no-framework.md)
- [Defaults that were rejected](explanation/rejected-defaults.md)

## Generated pages

[reference/palette.md](reference/palette.md) is produced from the live config by
`tools/palette-report.py`. Edit the `PAL` table in `config/zsh/.zshrc` and
regenerate rather than editing the page:

```bash
python3 tools/palette-report.py --markdown
```
