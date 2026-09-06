#!/usr/bin/env python3
"""Measure the palette declared in config/zsh/.zshrc.

Reads the PAL table out of the shell config and reports, for every colour,
its APCA contrast against the terminal background and its OKLCH coordinates,
plus the CIEDE2000 separation between colours that share a column.

    python3 tools/palette-report.py            # human-readable
    python3 tools/palette-report.py --markdown # the tables in docs/reference/palette.md

The reference doc is generated from this so it cannot drift from the config.
"""
import argparse, itertools, math, pathlib, re, sys

BG = (0x28, 0x2C, 0x34)  # Ghostty default background

# --- colour science -------------------------------------------------------
def _lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def apca(txt, bg):
    """APCA 0.1.9 lightness contrast. Sign dropped; callers want magnitude."""
    Y = lambda c: (0.2126729 * (c[0] / 255) ** 2.4 + 0.7151522 * (c[1] / 255) ** 2.4
                   + 0.0721750 * (c[2] / 255) ** 2.4)
    clip = lambda y: y if y > 0.022 else y + (0.022 - y) ** 1.414
    Yt, Yb = clip(Y(txt)), clip(Y(bg))
    if Yb > Yt:
        S = (Yb ** 0.56 - Yt ** 0.57) * 1.14
        return 0.0 if abs(S) < 0.1 else abs((S - 0.027) * 100)
    S = (Yb ** 0.65 - Yt ** 0.62) * 1.14
    return 0.0 if abs(S) < 0.1 else abs((S + 0.027) * 100)

def oklch(c):
    r, g, b = (_lin(x) for x in c)
    l = (0.4122214708*r + 0.5363325363*g + 0.0514459929*b) ** (1/3)
    m = (0.2119034982*r + 0.6806995451*g + 0.1073969566*b) ** (1/3)
    s = (0.0883024619*r + 0.2817188376*g + 0.6299787005*b) ** (1/3)
    L = 0.2104542553*l + 0.7936177850*m - 0.0040720468*s
    a = 1.9779984951*l - 2.4285922050*m + 0.4505937099*s
    bb = 0.0259040371*l + 0.7827717662*m - 0.8086757660*s
    return L, math.hypot(a, bb), math.degrees(math.atan2(bb, a)) % 360

def oklch_to_srgb(L, C, H):
    """OKLCH -> sRGB, clamped into gamut."""
    a, b = C * math.cos(math.radians(H)), C * math.sin(math.radians(H))
    l = (L + 0.3963377774*a + 0.2158037573*b) ** 3
    m = (L - 0.1055613458*a - 0.0638541728*b) ** 3
    s_ = (L - 0.0894841775*a - 1.2914855480*b) ** 3
    r = 4.0767416621*l - 3.3077115913*m + 0.2309699292*s_
    g = -1.2684380046*l + 2.6097574011*m - 0.3413193965*s_
    bb = -0.0041960863*l - 0.7034186147*m + 1.7076147010*s_
    def enc(x):
        x = max(0.0, min(1.0, x))
        return round(255 * (12.92*x if x <= 0.0031308 else 1.055*x**(1/2.4) - 0.055))
    return enc(r), enc(g), enc(bb)


def solve(target_lc, hue, chroma):
    """Find the sRGB colour at `hue`/`chroma` whose APCA contrast is target_lc.

    Reduces chroma when the requested combination falls outside sRGB, so it
    always returns something renderable. Returns (rgb, achieved_lc, chroma).
    """
    for ch in (chroma * (1 - 0.06*k) for k in range(18)):
        lo, hi = 0.30, 0.99
        for _ in range(60):
            mid = (lo + hi) / 2
            if apca(oklch_to_srgb(mid, ch, hue), BG) < target_lc:
                lo = mid
            else:
                hi = mid
        c = oklch_to_srgb(hi, ch, hue)
        L, C, H = oklch(c)
        if abs(apca(c, BG) - target_lc) < 1.2 and abs(C - ch) < 0.012:
            return c, apca(c, BG), C
    c = oklch_to_srgb(hi, chroma, hue)
    return c, apca(c, BG), oklch(c)[1]


def _lab(c):
    r, g, b = (_lin(x) for x in c)
    X = 0.4124*r + 0.3576*g + 0.1805*b
    Y = 0.2126*r + 0.7152*g + 0.0722*b
    Z = 0.0193*r + 0.1192*g + 0.9505*b
    f = lambda t: t ** (1/3) if t > 216/24389 else (841/108)*t + 4/29
    fx, fy, fz = f(X/0.95047), f(Y), f(Z/1.08883)
    return 116*fy - 16, 500*(fx - fy), 200*(fy - fz)

def de2000(c1, c2):
    L1, a1, b1 = _lab(c1); L2, a2, b2 = _lab(c2)
    C1, C2 = math.hypot(a1, b1), math.hypot(a2, b2)
    Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb**7 / (Cb**7 + 25**7))) if Cb else 0
    a1p, a2p = (1+G)*a1, (1+G)*a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360
    h2p = math.degrees(math.atan2(b2, a2p)) % 360
    dLp, dCp = L2 - L1, C2p - C1p
    if C1p * C2p == 0: dhp = 0
    elif abs(h2p - h1p) <= 180: dhp = h2p - h1p
    elif h2p - h1p > 180: dhp = h2p - h1p - 360
    else: dhp = h2p - h1p + 360
    dHp = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dhp) / 2)
    Lbp, Cbp = (L1 + L2) / 2, (C1p + C2p) / 2
    if C1p * C2p == 0: hbp = h1p + h2p
    elif abs(h1p - h2p) <= 180: hbp = (h1p + h2p) / 2
    elif h1p + h2p < 360: hbp = (h1p + h2p + 360) / 2
    else: hbp = (h1p + h2p - 360) / 2
    T = (1 - 0.17*math.cos(math.radians(hbp-30)) + 0.24*math.cos(math.radians(2*hbp))
         + 0.32*math.cos(math.radians(3*hbp+6)) - 0.20*math.cos(math.radians(4*hbp-63)))
    Sl = 1 + (0.015*(Lbp-50)**2) / math.sqrt(20 + (Lbp-50)**2)
    Sc, Sh = 1 + 0.045*Cbp, 1 + 0.015*Cbp*T
    Rt = -math.sin(math.radians(60 * math.exp(-((hbp-275)/25)**2))) * \
         (2 * math.sqrt(Cbp**7 / (Cbp**7 + 25**7)) if Cbp else 0)
    return math.sqrt((dLp/Sl)**2 + (dCp/Sc)**2 + (dHp/Sh)**2 + Rt*(dCp/Sc)*(dHp/Sh))

# --- read the config ------------------------------------------------------
def load_palette(path):
    text = path.read_text()
    block = re.search(r"typeset -gA PAL=\((.*?)\n\)", text, re.S)
    if not block:
        sys.exit(f"no PAL table found in {path}")
    pal = {}
    for line in block.group(1).splitlines():
        m = re.match(r"\s*(\w+)\s+([0-9a-fA-F]{6})\b", line)
        if m:
            pal[m.group(1)] = tuple(int(m.group(2)[i:i+2], 16) for i in (0, 2, 4))
    return pal

# Colours that appear in the same visual context and so must be told apart.
COLUMNS = {
    "filename":    ["dir", "link", "exe", "archive", "alert", "media", "special", "ink"],
    "permissions": ["r_u", "r_g", "r_o", "w_u", "w_g", "w_o", "x_u", "x_g", "x_o", "setid", "rule"],
    "ownership":   ["you", "root", "grp", "quiet"],
    "size":        ["n_b", "n_k", "n_m", "n_g", "n_t"],
    "git":         ["g_add", "g_mod", "g_del", "g_ren", "g_typ", "g_con", "quiet"],
    "neutrals":    ["ink", "ink2", "muted", "quiet", "rule"],
}
FLOOR = 26.0  # no *foreground* colour may fall below this APCA Lc
# Roles used as a background rather than as text. Text contrast is not a
# meaningful measure for these, so they sit outside the floor check.
BACKGROUNDS = {"selbg"}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--markdown", action="store_true")
    ap.add_argument("--check", action="store_true",
                    help="exit non-zero if any colour breaks the contrast floor")
    ap.add_argument("--solve", nargs=3, metavar=("LC", "HUE", "CHROMA"), type=float,
                    help="find the hex for a target APCA Lc at an OKLCH hue/chroma")
    args = ap.parse_args()

    if args.solve:
        lc, hue, chroma = args.solve
        c, got, gotc = solve(lc, hue, chroma)
        print("#%02x%02x%02x" % c)
        print(f"  APCA Lc {got:.1f} (asked {lc:g})   hue {oklch(c)[2]:.0f}°"
              f"   chroma {gotc:.3f}" + ("  [reduced to fit sRGB]" if gotc < chroma - 0.005 else ""))
        return

    root = pathlib.Path(__file__).resolve().parent.parent
    pal = load_palette(root / "config" / "zsh" / ".zshrc")
    md = args.markdown

    rows = []
    for name, c in sorted(pal.items(), key=lambda kv: -apca(kv[1], BG)):
        L, C, H = oklch(c)
        rows.append((name, "%02x%02x%02x" % c, apca(c, BG), L, C, H))
    fg = {k: v for k, v in pal.items() if k not in BACKGROUNDS}

    if md:
        print("| role | hex | APCA Lc | OKLCH L | chroma | hue |")
        print("|---|---|--:|--:|--:|--:|")
        for n, h, lc, L, C, H in rows:
            shown = "—" if n in BACKGROUNDS else f"{lc:.1f}"
            print(f"| `{n}` | `#{h}` | {shown} | {L:.3f} | {C:.3f} | {H:.0f}° |")
    else:
        print(f"{'role':<10} {'hex':<9} {'Lc':>6} {'okL':>6} {'okC':>6} {'hue':>5}")
        print("-" * 46)
        for n, h, lc, L, C, H in rows:
            if n in BACKGROUNDS:
                print(f"{n:<10} #{h:<8} {'  (bg)':>6} {L:>6.3f} {C:>6.3f} {H:>5.0f}")
                continue
            flag = "  << BELOW FLOOR" if lc < FLOOR else ""
            print(f"{n:<10} #{h:<8} {lc:>6.1f} {L:>6.3f} {C:>6.3f} {H:>5.0f}{flag}")

    print(f"\n{'##' if md else ''} Separation within each column (CIEDE2000)\n")
    if md:
        print("| column | roles | minimum ΔE2000 | closest pair |")
        print("|---|--:|--:|---|")
    for col, members in COLUMNS.items():
        present = [m for m in members if m in pal]
        pairs = sorted((de2000(pal[a], pal[b]), a, b)
                       for a, b in itertools.combinations(present, 2))
        if not pairs:
            continue
        d, a, b = pairs[0]
        if md:
            print(f"| {col} | {len(present)} | {d:.1f} | `{a}` / `{b}` |")
        else:
            print(f"  {col:<13} {len(present):>2} roles   min dE {d:>5.1f}   ({a} / {b})")

    worst = min(apca(c, BG) for c in fg.values())
    if not md:
        print(f"\n  lowest foreground contrast: Lc {worst:.1f} (floor is {FLOOR})")
    if args.check and worst < FLOOR:
        sys.exit(f"FAIL: a colour is below the Lc {FLOOR} floor")

if __name__ == "__main__":
    main()
