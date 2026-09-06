# How to change the prompt

The prompt is Powerlevel10k, configured by
[`config/zsh/.p10k.zsh`](../../config/zsh/.p10k.zsh).

## Reconfigure interactively

```bash
p10k configure
```

This walks through a series of choices and **rewrites `.p10k.zsh` completely**.
Because that file is symlinked into this repository, the change lands in your
working tree — review it before committing:

```bash
git diff --stat config/zsh/.p10k.zsh
```

The file is about 2000 lines of generated configuration with every option
present and most commented out. A large diff is normal.

## Change one thing without regenerating

Edit `.p10k.zsh` directly; the options are grouped and commented. Common ones:

| Setting | Controls |
|---|---|
| `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` | Segments on the left |
| `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` | Segments on the right |
| `POWERLEVEL9K_MODE` | Glyph set — needs a Nerd Font |
| `POWERLEVEL9K_PROMPT_ADD_NEWLINE` | Blank line between prompts |
| `POWERLEVEL9K_*_FOREGROUND` | Per-segment colour |

Reload with `exec zsh`.

## About the instant prompt

The block at the top of `.zshrc` restores a cached prompt immediately, before
the rest of the configuration runs. It is why the shell feels instant despite
sourcing plugins.

Its one requirement: **nothing may print before it**. Anything that writes to
the terminal or asks for input has to go above the block. If you add a tool that
prints a warning on startup, you will get a p10k complaint — see
[troubleshoot.md](troubleshoot.md#p10k-warns-about-console-output-during-instant-prompt).

## The prompt palette is separate

`.p10k.zsh` carries its own colours and is **not** derived from the `PAL` table
in `.zshrc`. It is generated output, and regenerating it would discard anything
hand-wired into it.

The practical consequence: prompt colours and listing colours are two systems.
If you want them unified, set the `POWERLEVEL9K_*_FOREGROUND` values by hand to
match [reference/palette.md](../reference/palette.md), and accept that
`p10k configure` will overwrite them.
