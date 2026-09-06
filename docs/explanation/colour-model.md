# The colour model

Why the palette is built the way it is. For the numbers themselves, see
[reference/palette.md](../reference/palette.md); to change a colour, see
[how-to/retune-the-palette.md](../how-to/retune-the-palette.md).

## The ground

Every colour is solved against Ghostty's default background, `#282c34`. That
constant matters: contrast is a relationship, not a property of a colour, so a
palette is only "legible" relative to a stated background. Change the terminal
theme and the measurements stop being true.

## Why APCA rather than WCAG

WCAG 2.x contrast ratios are computed from a simple luminance ratio that is
known to misreport light-text-on-dark-background — the polarity a terminal
actually uses. It systematically overstates how readable dim text is on a dark
ground.

APCA (`Lc`, roughly 0–108) models polarity and spatial frequency, so it gives
usable answers for exactly this case. The floors used here:

| Tier | `Lc` | Used for |
|---:|---:|---|
| primary | 78 | filenames, table headers |
| secondary | 62 | supporting text |
| tertiary | 48 | metadata |
| recessive | 34 | deliberately quiet: ignored files, autosuggestions |
| structural | 26 | punctuation, rules — the floor |

Nothing that must be read sits below `Lc 30`.

The palette this replaced had punctuation at `Lc 0.0` — below the threshold
where APCA will even report a value, meaning it was not rendering as
distinguishable text at all. Git-ignored entries sat at `Lc 21`. Both were
invisible rather than subtle, which is not a judgement call but a measurement.

## Lightness carries hierarchy, hue carries category

These are separate perceptual channels and each is given exactly one job.

Five neutral tiers span the lightness axis. Category — is this a directory, a
symlink, a broken link — is hue, at roughly constant lightness so that no
category is inherently harder to read than another.

## The interesting case: an ordered scale

File size is *ordinal*. The instinct is a lightness ramp, dim to bright, because
lightness is the channel humans order most reliably.

That instinct is wrong here, and the reason is worth stating: every step of this
scale is **a number you have to read**. A lightness ramp necessarily makes one
end dimmer, so small files would be less legible than large ones — the encoding
would be fighting the content.

So lightness is held constant at `Lc 60` across all five magnitude steps, and
the ordering is carried by hue (cool → warm) and chroma (low → high) instead.
Measured spread across the five: `Lc 60.0` to `60.4`.

The unit suffix sits one tier down at `Lc 44` in the same hue, so `4.3` reads
before `MB` within a single token — a typographic hierarchy inside one word.

This is only possible because the terminal does 24-bit colour. The xterm-256
cube is too coarse to hold iso-lightness across the hue circle: the best
available cube approximation spans `Lc 52–70`, an 18-point spread.

## The permission block

`rwxr-xr-x` has two variables: which bit, and whose. Position already encodes
*whose* unambiguously, so colour spends itself on *which bit* — read is cyan,
write is amber, execute is green — giving vertical colour bands you can scan
without reading letters.

Lightness then ramps user → group → other, which is redundant with position and
therefore allowed to be subtle. Adjacent tiers separate by about ΔE 8, which
would be too close if colour were the only cue and is fine because it is not.

Chroma does one more job here: an unset bit (`-`) is achromatic, a set bit is
chromatic. Saturation itself encodes "this bit is on".

## How many categories a column can hold

Categorical colour tops out well below what a hue circle suggests — in context,
at speed, somewhere around eight distinguishable categories.

The filename column previously carried seventeen. Measured, several were below
the just-noticeable difference: directories and documents sat at ΔE 2.1, which
is not a subtle distinction but no distinction.

It now carries eight, with a measured minimum separation of ΔE 10.6. The
reduction costs nothing, because `--icons=always` already encodes fine-grained
file type in the glyph. Colour was repeating information the icon carried
better.

## Graceful degradation

The palette is declared once as sRGB hex. At startup it is compiled to SGR
escape parameters: 24-bit when `$COLORTERM` advertises it, otherwise quantised
to the xterm-256 cube (near-neutrals to the 24-step grey ramp, chromatic
colours to the 6×6×6 cube).

`zsh` will happily emit 24-bit escapes into a terminal that cannot render them,
so prompt- and zle-spelled colours are mirrored into a second table rather than
written as raw hex. Both spellings degrade together.
