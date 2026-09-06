# Palette

<!-- The tables below are generated. Regenerate with:
     python3 tools/palette-report.py --markdown
     Do not hand-edit; edit the PAL table in config/zsh/.zshrc instead. -->

Every colour in the system, measured against the terminal background `#282c34`.
For the reasoning see [explanation/colour-model.md](../explanation/colour-model.md);
to change one safely see
[how-to/retune-the-palette.md](../how-to/retune-the-palette.md).

## Reading these numbers

- **APCA `Lc`** — perceptual contrast against the background. Higher is more
  legible. The floor for this palette is 26; anything readable sits above 30.
  Background roles show `—` because text contrast is not meaningful for them.
- **OKLCH L / chroma / hue** — perceptually uniform coordinates. Lightness
  carries hierarchy, hue carries category.
- **ΔE2000** — perceptual distance. Below about 2.3 two colours are
  indistinguishable; 10 is a comfortable separation.

## Roles

| role | hex | APCA Lc | OKLCH L | chroma | hue |
|---|---|--:|--:|--:|--:|
| `ink` | `#d7d7d7` | 78.1 | 0.879 | 0.000 | 90° |
| `g_con` | `#ffc2b9` | 74.2 | 0.867 | 0.072 | 28° |
| `exe` | `#84e193` | 72.1 | 0.832 | 0.141 | 148° |
| `link` | `#6ad9ee` | 70.4 | 0.828 | 0.105 | 212° |
| `dir` | `#afcbff` | 70.3 | 0.840 | 0.079 | 263° |
| `setid` | `#ffb4aa` | 68.4 | 0.838 | 0.089 | 28° |
| `x_u` | `#8ad896` | 68.3 | 0.815 | 0.120 | 148° |
| `r_u` | `#76d2f4` | 68.1 | 0.819 | 0.100 | 224° |
| `w_u` | `#e7c264` | 68.0 | 0.828 | 0.121 | 88° |
| `archive` | `#ffb773` | 68.0 | 0.833 | 0.119 | 63° |
| `you` | `#73cff1` | 66.4 | 0.810 | 0.100 | 224° |
| `g_mod` | `#e9be49` | 66.4 | 0.819 | 0.140 | 88° |
| `g_add` | `#7ad789` | 66.3 | 0.802 | 0.141 | 148° |
| `g_ren` | `#68cff5` | 66.0 | 0.807 | 0.109 | 225° |
| `media` | `#ffa6e5` | 66.0 | 0.832 | 0.130 | 338° |
| `special` | `#c4b6ff` | 64.2 | 0.814 | 0.102 | 293° |
| `alert` | `#ffa9a1` | 64.1 | 0.817 | 0.103 | 25° |
| `root` | `#ffa499` | 62.2 | 0.807 | 0.110 | 27° |
| `g_del` | `#ffa498` | 62.1 | 0.806 | 0.110 | 28° |
| `ink2` | `#bcbcbc` | 62.1 | 0.795 | 0.000 | 90° |
| `g_typ` | `#c3b1fe` | 62.1 | 0.803 | 0.109 | 295° |
| `n_m` | `#8bc793` | 60.4 | 0.775 | 0.096 | 148° |
| `n_b` | `#a1bbdc` | 60.2 | 0.784 | 0.055 | 255° |
| `b_dirty` | `#d6b561` | 60.2 | 0.785 | 0.110 | 88° |
| `n_t` | `#ffa25d` | 60.1 | 0.793 | 0.139 | 56° |
| `n_k` | `#7ac5c3` | 60.0 | 0.774 | 0.075 | 194° |
| `n_g` | `#d8b45c` | 60.0 | 0.784 | 0.115 | 87° |
| `x_g` | `#83b789` | 52.4 | 0.730 | 0.086 | 148° |
| `r_g` | `#77b3ca` | 52.4 | 0.734 | 0.070 | 224° |
| `w_g` | `#c1a86a` | 52.3 | 0.739 | 0.086 | 88° |
| `b_clean` | `#87b58d` | 52.0 | 0.729 | 0.076 | 148° |
| `date` | `#9aa8b9` | 50.1 | 0.726 | 0.029 | 253° |
| `linkpath` | `#78aabd` | 48.1 | 0.709 | 0.060 | 224° |
| `muted` | `#a2a3a2` | 48.1 | 0.714 | 0.002 | 146° |
| `grp` | `#86a7be` | 48.1 | 0.712 | 0.050 | 239° |
| `u_m` | `#7da582` | 44.2 | 0.683 | 0.067 | 148° |
| `u_b` | `#8b9db4` | 44.2 | 0.690 | 0.040 | 255° |
| `u_g` | `#b09960` | 44.2 | 0.690 | 0.080 | 88° |
| `u_t` | `#cc8d60` | 44.2 | 0.696 | 0.098 | 56° |
| `u_k` | `#73a4a2` | 44.1 | 0.683 | 0.052 | 193° |
| `r_o` | `#719aaa` | 40.4 | 0.662 | 0.051 | 224° |
| `w_o` | `#a39269` | 40.2 | 0.665 | 0.060 | 88° |
| `x_o` | `#789c7c` | 40.0 | 0.657 | 0.062 | 148° |
| `quiet` | `#878888` | 34.3 | 0.626 | 0.001 | 197° |
| `rule` | `#777777` | 26.4 | 0.569 | 0.000 | 90° |
| `selbg` | `#41464f` | — | 0.393 | 0.017 | 262° |

## Separation within each column (CIEDE2000)

| column | roles | minimum ΔE2000 | closest pair |
|---|--:|--:|---|
| filename | 8 | 10.6 | `dir` / `special` |
| permissions | 11 | 7.8 | `r_g` / `r_o` |
| ownership | 4 | 12.7 | `you` / `grp` |
| size | 5 | 16.9 | `n_g` / `n_t` |
| git | 7 | 7.8 | `g_del` / `g_con` |
| neutrals | 5 | 6.4 | `quiet` / `rule` |

A minimum of 10.6 in the filename column is the binding constraint on how many
categories that column can hold. The permission and git columns sit lower by
design: position within `rwxr-xr-x` already distinguishes the permission tiers,
and the two close git flags (`g_del`, `g_con`) differ additionally in weight.

## Where each role is used

| Group | Roles | Applies to |
|---|---|---|
| Neutrals | `ink` `ink2` `muted` `quiet` `rule` | Text hierarchy, punctuation, headers |
| Filename | `dir` `link` `linkpath` `exe` `archive` `alert` `media` `special` | The name column in `ls` output and the completion menu |
| Permissions | `r_*` `w_*` `x_*` `setid` | The `rwxr-xr-x` block; suffix is user / group / other |
| Ownership | `you` `root` `grp` | User and group columns |
| Git | `g_add` `g_mod` `g_del` `g_ren` `g_typ` `g_con`, `b_clean` `b_dirty` | Per-file status flags and branch state |
| Size | `n_b` … `n_t`, `u_b` … `u_t` | Magnitude and unit, `<1K` through `≥TB` |
| Other | `date` `selbg` | Timestamp column; fzf selection bar |

## Consumers

All derived from the one table at shell startup:

| Consumer | Variable |
|---|---|
| `eza` | `EZA_COLORS` |
| `ls`, completion menu | `LS_COLORS` + `list-colors` |
| `fzf` | `FZF_DEFAULT_OPTS --color=` |
| `zsh-syntax-highlighting` | `ZSH_HIGHLIGHT_STYLES` |
| `zsh-autosuggestions` | `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` |
| Completion messages | `zstyle … format` |

Two compiled forms exist because the spellings differ: `SGR` holds raw escape
parameters (`38;2;r;g;b` or `38;5;N`) for `EZA_COLORS` and `LS_COLORS`; `ZC`
holds the zle/prompt spelling (`#rrggbb` or a bare index) for everything else.
Both quantise to the 256-colour cube together when `$COLORTERM` does not
advertise truecolour.

## Not covered

The Powerlevel10k prompt has its own palette in `config/zsh/.p10k.zsh`, which is
generated by `p10k configure` and is not derived from this table.
