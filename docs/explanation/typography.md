# Typography

The terminal is a text-rendering surface, and most of its typographic decisions
are made by default rather than chosen.

## The typeface

JetBrains Mono at 16 px, with Symbols Nerd Font Mono as fallback.

The two-family split matters. Patched "Nerd Font" builds of a typeface graft
icon glyphs into the font file itself, which usually costs the original's
hinting and sometimes its ligatures. Declaring a symbols-only fallback keeps
JetBrains Mono intact and lets the fallback supply only the glyphs the primary
lacks — which is precisely what a fallback is for.

JetBrains Mono is a reasonable default for long sessions: a tall x-height
(≈0.55 em) that holds up at small sizes, and unambiguous `0`/`O` and `1`/`l`/`I`.

## Underline is a third channel, and usually one too many

The listing header was originally bold **and** underlined **and** coloured —
three simultaneous encodings of "this is a header", where the row's position
already makes it obvious.

The underline was also actively harmful. A monospace underline is drawn as a
continuous rule close to the baseline, and it clips descenders: the `p` in
"Group" loses its tail. Bold at the brightest tier says "header" without
mutilating a glyph.

The general rule: two channels are plenty, and when a third is added it should
be because the first two are genuinely insufficient — not for emphasis.

## Alignment is legibility

`--time-style=long-iso` renders timestamps as `2026-09-06 21:16` — fixed width,
unambiguous, and sortable by eye. The default format varies in width between
recent and older files, so the column edge frays and dates cannot be compared
by scanning down.

`--smart-group` drops the group column when it duplicates the owner, which for
a single-user machine is nearly always. Removing a redundant column is a
typographic act: it shortens the line and moves the fields you do read closer
to the left margin.

## Hierarchy inside a single token

`4.3 MB` is one visual unit but two pieces of information, and they are not
equally important. The number is set at `Lc 60`, the unit one tier down at
`Lc 44`, in the same hue. The magnitude reads first; the unit is available
without competing.

## What the terminal still does by default

Two things are left to Ghostty's defaults and are worth knowing about:

- **Line height.** JetBrains Mono is drawn for roughly 1.2 line spacing.
  Ghostty derives cell height from font metrics, which tends to run tighter.
  `adjust-cell-height = 12%` opens it up.
- **Stem weight.** macOS renders Ghostty noticeably thinner than Terminal.app
  does. `font-thicken = true` compensates.

Neither is set, because both are preference rather than correctness. See
[how-to/adjust-typography.md](../how-to/adjust-typography.md).
