# How to adjust typography

Terminal typography lives in
[`config/ghostty/config`](../../config/ghostty/config), which is deliberately
short. Reasoning: [explanation/typography.md](../explanation/typography.md).

Ghostty reloads its configuration on save in most cases; if a change does not
appear, open a new window.

## Current settings

```
font-size = 16
font-family = JetBrains Mono
font-family = Symbols Nerd Font Mono
```

The second `font-family` is a fallback, not a replacement: glyphs missing from
JetBrains Mono are taken from the symbols font. Order matters.

## Open up the line spacing

JetBrains Mono is drawn for roughly 1.2 line spacing; Ghostty's derived cell
height runs tighter.

```
adjust-cell-height = 12%
```

Percentages are relative to the computed cell. Try 8–15%; past about 20% the
grid starts to feel disconnected.

## Thicken the strokes

macOS renders Ghostty noticeably thinner than Terminal.app.

```
font-thicken = true
```

## Turn off ligatures

JetBrains Mono ligates `->`, `=>`, `!=` and similar by default. To disable:

```
font-feature = -calt
```

Worth doing if you work with code where `=>` and `>=` must be told apart at a
glance, or if ligature glyphs confuse column alignment in your editor.

## Change the background

The whole palette is measured against `#282c34`. Changing this invalidates every
contrast figure in [reference/palette.md](../reference/palette.md).

```
background = #1e1e2e
```

If you do, follow
[retune-the-palette.md](retune-the-palette.md#retarget-a-different-terminal-background).

## Change the size

```
font-size = 15
```

APCA contrast is partly a function of size and weight — smaller text needs more
contrast for the same legibility. Dropping much below 14 makes the `Lc 26`
structural tier marginal; raise `rule` and `quiet` a few points if you do.

## Check what Ghostty is actually using

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config
/Applications/Ghostty.app/Contents/MacOS/ghostty +list-fonts | grep -i jetbrains
```

The second is the quick way to find out whether a font name is spelled the way
Ghostty expects.
