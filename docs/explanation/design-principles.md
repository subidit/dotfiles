# Design principles

The rules the rest of this configuration follows. Everything else in
`docs/explanation/` is one of these worked out in detail.

## 1. `$HOME` is an interface, not a junk drawer

A home directory should be legible at a glance. The XDG base directory
specification already defines where things belong; most tools honour it, and
the ones that do not can usually be told to. So the configuration exiles
everything it can and accepts a small, fixed set of hidden entries rather than
an ever-growing pile.

Worked out in [XDG and a clean `$HOME`](xdg-and-a-clean-home.md).

## 2. One colour system, not four

A terminal accumulates palettes: the ANSI 16 from the terminal theme, whatever
`eza` was told, whatever `fzf` defaults to, whatever the syntax highlighter
ships. Each is defensible alone; together they are noise, because the same
semantic idea — "this is a path", "this needs attention" — arrives in a
different colour depending on which program drew it.

Here a single table of 46 colours is declared once and every consumer is
derived from it. Adding a colour means adding a row, not editing five files.

Worked out in [The colour model](colour-model.md).

## 3. Perceptual channels carry meaning, and only one meaning each

Lightness carries hierarchy. Hue carries category. Where a scale must be
*ordered*, the ordering goes into hue and chroma, because lightness is already
spoken for by legibility.

The corollary is that nothing gets encoded twice. Icons already tell you a file
is a video; colour does not need to repeat it, and the eight-way colour
distinction that repetition demands is past what anyone decodes at a glance.

## 4. Measured, not eyeballed

Contrast targets are APCA `Lc` values against the actual terminal background.
Separation between colours that share a column is CIEDE2000. Both are checked
by `tools/palette-report.py --check`, which fails if any foreground colour
falls below the legibility floor.

This is the difference between "that looks a bit dim" and "that is `Lc 0.0`,
it is not rendering at all" — which is what the check found in the palette this
repository replaced.

## 5. Degrade honestly

The configuration targets Ghostty with 24-bit colour, and says so. But the same
palette is quantised to the xterm-256 cube when `$COLORTERM` does not advertise
truecolour, so an `ssh` into an older box gets the nearest expressible design
rather than garbage or a fallback that looks unrelated.

## 6. No framework

There is no plugin manager and no framework. Startup is roughly 50 ms and every
line is one someone chose.

Worked out in [Why no framework](no-framework.md).

## 7. A default is a decision

Inherited defaults get the same scrutiny as new settings. Several common ones
are deliberately *not* used here, and the reasons are written down rather than
left as an absence someone re-adds later.

Worked out in [Defaults that were rejected](rejected-defaults.md).
