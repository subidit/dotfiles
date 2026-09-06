# How to change a colour

The palette is a single table with a measurable contract. This is how to change
it without breaking that contract.

Background: [explanation/colour-model.md](../explanation/colour-model.md).
Current values: [reference/palette.md](../reference/palette.md).

## Change one colour

Edit the `PAL` table in [`config/zsh/.zshrc`](../../config/zsh/.zshrc):

```zsh
typeset -gA PAL=(
  dir        afcbff   # 70  263
  …
)
```

Then check it and reload:

```bash
python3 tools/palette-report.py --check
exec zsh
```

`--check` fails if any foreground colour has fallen below the `Lc 26` floor.

You do not need to touch `EZA_COLORS`, `LS_COLORS`, fzf or the highlighter —
all of them are derived from this table at startup.

## Keep a change inside the system

Two questions before committing a value.

**Is the lightness right for its tier?** The five neutral tiers are `Lc`
78 / 62 / 48 / 34 / 26. A colour should sit at the tier matching its importance,
not brighter because you like it. Check the reported `Lc`.

**Is it far enough from its neighbours?** Run the report and read the separation
table. If the minimum ΔE in that column drops below about 10, the two colours
will be hard to tell apart in the one place it matters.

```bash
python3 tools/palette-report.py | tail -12
```

## Solve for a target instead of guessing

To get a specific hue at a specific contrast, ask for it:

```bash
python3 tools/palette-report.py --solve <Lc> <hue> <chroma>
```

```
$ python3 tools/palette-report.py --solve 60 300 0.12
#c8aafd
  APCA Lc 60.1 (asked 60)   hue 300°   chroma 0.119
```

Arguments are the target APCA `Lc`, the OKLCH hue in degrees, and chroma.
Useful chroma ranges: 0.03–0.06 for near-neutrals, 0.08–0.14 for ordinary
category colours, up to about 0.20 for something that must shout.

Not every combination exists in sRGB — saturated reds and blues run out of
gamut at high lightness. The solver reduces chroma until the colour is
renderable and says so:

```
$ python3 tools/palette-report.py --solve 70 25 0.20
#ffb8b0
  APCA Lc 70.0 (asked 70)   hue 26°   chroma 0.084  [reduced to fit sRGB]
```

Contrast is held exactly; chroma is what gives. If you need both, lower the
target `Lc`.

## Retarget a different terminal background

Every number assumes `#282c34`. If you change the Ghostty theme, the
measurements stop being true.

Update `BG` at the top of
[`tools/palette-report.py`](../../tools/palette-report.py), re-run the report,
and expect to move most of the neutrals — contrast is a relationship, so a
lighter ground makes every foreground less legible at once.

## Add a new role

1. Add a row to `PAL`.
2. Reference it as `${SGR[name]}` for `EZA_COLORS` / `LS_COLORS`, or
   `${ZC[name]}` for anything zle- or prompt-spelled. Using raw `#hex` will
   emit 24-bit escapes even on terminals that cannot render them.
3. If it is a background rather than text, add it to `BACKGROUNDS` in
   `tools/palette-report.py` so the contrast floor does not apply.
4. If it shares a column with existing roles, add it to that column's list in
   `COLUMNS` so the separation check covers it.
5. Regenerate the reference:

```bash
python3 tools/palette-report.py --markdown   # paste into docs/reference/palette.md
```

## Check the 256-colour fallback

The palette is quantised when `$COLORTERM` does not advertise truecolour:

```bash
COLORTERM= TERM=xterm-256color zsh -ic 'print ${SGR[dir]} ${ZC[dir]}'
# 38;5;153 153
COLORTERM=truecolor zsh -ic 'print ${SGR[dir]} ${ZC[dir]}'
# 38;2;175;203;255 #afcbff
```

A colour that looks wrong over `ssh` but right locally is usually one that
quantised into a neighbour's cube cell.
