# Troubleshooting

## Colours look wrong or garbled

Check what the terminal is advertising:

```bash
echo "$TERM / $COLORTERM"          # expect xterm-ghostty / truecolor
zsh -ic 'print ${SGR[dir]}'        # 38;2;… truecolour, 38;5;… quantised
```

If `$COLORTERM` is empty inside `tmux` or over `ssh`, the palette quantises to
256 colours by design. That is the fallback working, not a fault.

If colours are wrong only over `ssh`, a colour has likely quantised into a
neighbour's cube cell — see
[retune-the-palette.md](retune-the-palette.md#check-the-256-colour-fallback).

## The completion menu has no colour

`LS_COLORS` is generated at startup; if it is empty the `list-colors` zstyle
silently expands to nothing.

```bash
zsh -ic 'print ${#LS_COLORS}'      # expect a few hundred
```

Zero means the palette block did not run. Look for an error earlier in startup.

## New completions are not showing up

The `compinit` cache is rebuilt only when older than 24 hours. Force it:

```bash
rm ~/.cache/zsh/zcompdump && exec zsh
```

## `p10k` warns about console output during instant prompt

Something printed before the instant-prompt block. The usual causes are a
`brew shellenv` in the wrong file, or a tool's init script writing a warning.

Find it:

```bash
zsh -x -i -c exit 2>&1 | head -60
```

Anything that must print, or that prompts for input, has to go *above* the
instant-prompt block in `.zshrc`.

## The prompt draws over my output

`unsetopt PROMPT_SP` is deliberate. It removes the trailing-`%` marker, at the
cost of preserving output that does not end in a newline. If you would rather
keep the output, delete that line from `.zshrc`.

## `grep` behaves differently than I expect

It is real `grep` here, only with `--color=auto`. `rg` is deliberately not
aliased over it — see
[rejected-defaults](../explanation/rejected-defaults.md#alias-greprg).

## Startup feels slow

Measure first:

```bash
for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit; done 2>&1 | grep real
```

Expect roughly 0.05 s. If it is much worse, profile:

```bash
# temporarily, at the very top of .zshrc
zmodload zsh/zprof
# and at the very bottom
zprof
```

Common causes are a full `compinit` rebuild (once a day, expected) and slow
`eval "$(… init)"` lines from newly added tools.

## Icons render as boxes

The symbols font is missing:

```bash
brew install --cask font-symbols-only-nerd-font
/Applications/Ghostty.app/Contents/MacOS/ghostty +list-fonts | grep -i symbols
```

## A file reappeared in `$HOME`

Identify the owner, then follow
[keep-home-clean.md](keep-home-clean.md):

```bash
ls -A ~ | grep '^\.'
```

## Reverting entirely

```bash
./install.sh --unlink
ls ~/.dotfiles-backup/
```

Backups are restored by hand; nothing is deleted for you.
