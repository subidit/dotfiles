# Coordinated color palette — one source of truth for eza, completion menus,
# fzf, syntax highlighting, and autosuggestions, instead of four unrelated
# default color schemes in the same window.
#
# Ground: #282c34 (Ghostty's default background — the terminal this is tuned
# for; Apple Terminal / VSCodium inherit the same palette without re-tuning).
# Colors solved in OKLCH against that ground for target APCA contrast, then
# converted to sRGB. Two rules: LIGHTNESS carries hierarchy (five neutral
# tiers), HUE carries category, never rank.

typeset -gA PAL=(
  # neutral hierarchy — lightness is the only variable
  ink        d7d7d7   # primary text
  ink2       bcbcbc   # secondary
  muted      a2a3a2   # metadata
  quiet      878888   # recessive; still legible
  rule       777777   # punctuation/rules; the floor

  # filename categories — eight hues
  dir        afcbff
  link       6ad9ee
  linkpath   78aabd
  exe        84e193
  archive    ffb773
  alert      ffa9a1
  media      ffa6e5
  special    c4b6ff

  # permission bits — hue = which bit, lightness = whose bit
  r_u        76d2f4
  r_g        77b3ca
  r_o        719aaa
  w_u        e7c264
  w_g        c1a86a
  w_o        a39269
  x_u        8ad896
  x_g        83b789
  x_o        789c7c
  setid      ffb4aa

  # ownership
  you        73cff1
  root       ffa499
  grp        86a7be

  # git
  g_add      7ad789
  g_mod      e9be49
  g_del      ffa498
  g_ren      68cff5
  g_typ      c3b1fe
  g_con      ffc2b9
  b_clean    87b58d
  b_dirty    d6b561

  # file-size scale — iso-lightness, ordered by hue + chroma
  n_b        a1bbdc
  n_k        7ac5c3
  n_m        8bc793
  n_g        d8b45c
  n_t        ffa25d
  u_b        8b9db4
  u_k        73a4a2
  u_m        7da582
  u_g        b09960
  u_t        cc8d60

  date       9aa8b9
  selbg      41464f
)

# Compile the palette to SGR parameters once, at startup. 24-bit when the
# terminal advertises it; otherwise quantised to the xterm-256 cube so it
# degrades gracefully over ssh or a plain TERM.
typeset -gA SGR
() {
  local -a lv=(0 95 135 175 215 255)
  local truecolor=0
  [[ $COLORTERM == (truecolor|24bit) || $TERM == *(24bit|direct)* ]] && truecolor=1
  local k h r g b mx mn i t bd ci
  local -a ix
  for k h in ${(kv)PAL}; do
    r=$(( 16#${h[1,2]} )) g=$(( 16#${h[3,4]} )) b=$(( 16#${h[5,6]} ))
    if (( truecolor )); then
      SGR[$k]="38;2;$r;$g;$b"
      continue
    fi
    mx=$r; (( g > mx )) && mx=$g; (( b > mx )) && mx=$b
    mn=$r; (( g < mn )) && mn=$g; (( b < mn )) && mn=$b
    if (( mx - mn < 14 )); then                 # near-neutral: 24-step grey ramp
      ci=$(( ((r + g + b) / 3 - 8 + 5) / 10 ))
      (( ci < 0 )) && ci=0
      (( ci > 23 )) && ci=23
      SGR[$k]="38;5;$(( 232 + ci ))"
    else                                        # chromatic: 6x6x6 cube
      ix=()
      for t in $r $g $b; do
        bd=999
        for i in {1..6}; do
          local d=$(( t - lv[i] )); (( d < 0 )) && d=$(( -d ))
          (( d < bd )) && { bd=$d; ci=$(( i - 1 )); }
        done
        ix+=$ci
      done
      SGR[$k]="38;5;$(( 16 + 36*ix[1] + 6*ix[2] + ix[3] ))"
    fi
  done
}

# zle/prompt escapes take a different spelling than raw SGR; mirror the
# table so it degrades the same way everywhere.
typeset -gA ZC
() {
  local k
  for k in ${(k)PAL}; do
    if [[ ${SGR[$k]} == 38\;5\;* ]]; then
      ZC[$k]="${SGR[$k]#38;5;}"
    else
      ZC[$k]="#${PAL[$k]}"
    fi
  done
}

# --- eza --------------------------------------------------------------
typeset -a _eza=(
  "di=1;${SGR[dir]}" "ln=${SGR[link]}" "lp=${SGR[linkpath]}" "or=${SGR[alert]}"
  "ex=1;${SGR[exe]}" "fi=${SGR[ink]}"
  "pi=${SGR[special]}" "so=${SGR[special]}" "bd=${SGR[special]}" "cd=${SGR[special]}"
  "sp=${SGR[special]}" "mp=${SGR[special]}" "bO=${SGR[alert]}"
  "ur=${SGR[r_u]}" "uw=${SGR[w_u]}" "ux=${SGR[x_u]}" "ue=${SGR[x_u]}"
  "gr=${SGR[r_g]}" "gw=${SGR[w_g]}" "gx=${SGR[x_g]}"
  "tr=${SGR[r_o]}" "tw=${SGR[w_o]}" "tx=${SGR[x_o]}"
  "su=1;${SGR[setid]}" "sf=1;${SGR[setid]}" "oc=${SGR[muted]}" "xa=${SGR[linkpath]}"
  "uu=1;${SGR[you]}" "uR=1;${SGR[root]}" "un=${SGR[quiet]}"
  "gu=${SGR[grp]}"   "gR=${SGR[root]}"   "gn=${SGR[quiet]}"
  "nb=${SGR[n_b]}" "nk=${SGR[n_k]}" "nm=${SGR[n_m]}" "ng=${SGR[n_g]}" "nt=${SGR[n_t]}"
  "ub=${SGR[u_b]}" "uk=${SGR[u_k]}" "um=${SGR[u_m]}" "ug=${SGR[u_g]}" "ut=${SGR[u_t]}"
  "ga=${SGR[g_add]}" "gm=${SGR[g_mod]}" "gd=${SGR[g_del]}" "gv=${SGR[g_ren]}"
  "gt=${SGR[g_typ]}" "gi=${SGR[quiet]}" "gc=1;${SGR[g_con]}"
  "Gm=1;${SGR[exe]}" "Go=${SGR[dir]}" "Gc=${SGR[b_clean]}" "Gd=${SGR[b_dirty]}"
  "da=${SGR[date]}" "in=${SGR[quiet]}" "bl=${SGR[quiet]}"
  "lc=${SGR[quiet]}" "lm=${SGR[w_u]}" "df=${SGR[archive]}" "ds=${SGR[archive]}"
  "cc=${SGR[alert]}"
  "xx=${SGR[rule]}"
  "hd=1;${SGR[ink]}"
  "im=${SGR[media]}" "vi=${SGR[media]}" "mu=${SGR[media]}" "lo=${SGR[media]}"
  "cr=${SGR[alert]}" "co=${SGR[archive]}" "bu=${SGR[archive]}"
  "tm=${SGR[quiet]}" "cm=${SGR[quiet]}" "do=${SGR[ink]}" "sc=${SGR[ink]}"
)
# Per-extension rules. The two-letter codes above color eza's own UI columns and
# its built-in file kinds; a plain source or config file still falls through to
# `fi`, which is one flat ink. These globs give the filenames themselves a hue,
# under the same rule as everything else: HUE IS CATEGORY, never rank.
typeset -a _eza_ext=(
  # source — green, the same family as an executable, because it's code you run
  '*.py=${SGR[exe]}' '*.rs=${SGR[exe]}' '*.go=${SGR[exe]}' '*.c=${SGR[exe]}'
  '*.h=${SGR[exe]}' '*.cpp=${SGR[exe]}' '*.swift=${SGR[exe]}' '*.lua=${SGR[exe]}'
  '*.rb=${SGR[exe]}' '*.java=${SGR[exe]}' '*.zsh=${SGR[exe]}' '*.sh=${SGR[exe]}'
  '*.bash=${SGR[exe]}' '*.fish=${SGR[exe]}' '*.vim=${SGR[exe]}' '*.el=${SGR[exe]}'

  # web/markup — cyan, a lighter weight of the same idea
  '*.ts=${SGR[link]}' '*.tsx=${SGR[link]}' '*.js=${SGR[link]}' '*.jsx=${SGR[link]}'
  '*.html=${SGR[link]}' '*.css=${SGR[link]}' '*.scss=${SGR[link]}' '*.svelte=${SGR[link]}'
  '*.vue=${SGR[link]}' '*.sql=${SGR[link]}'

  # config — amber, the "this changes behaviour" hue
  '*.json=${SGR[g_mod]}' '*.yaml=${SGR[g_mod]}' '*.yml=${SGR[g_mod]}'
  '*.toml=${SGR[g_mod]}' '*.ini=${SGR[g_mod]}' '*.conf=${SGR[g_mod]}'
  '*.cfg=${SGR[g_mod]}' '*.plist=${SGR[g_mod]}' '*rc=${SGR[g_mod]}'
  'Makefile=${SGR[g_mod]}' 'Dockerfile=${SGR[g_mod]}' 'justfile=${SGR[g_mod]}'

  # prose — lavender. NOT dir blue: a .md sat at the same hue as the folder next
  # to it, with only bold telling them apart. Lavender is nominally the devices
  # hue (pi/so/bd/cd above), but a socket or block device never shows up in a
  # directory you'd actually read, so that collision stays theoretical.
  '*.md=${SGR[special]}' '*.rst=${SGR[special]}' '*.org=${SGR[special]}'
  '*.tex=${SGR[special]}' '*.pdf=${SGR[special]}' '*.txt=${SGR[muted]}'
  'README=1;${SGR[ink]}' 'README.md=1;${SGR[ink]}' 'LICENSE=${SGR[muted]}'

  # archives — orange, matching eza's own compressed-file kind
  '*.zip=${SGR[archive]}' '*.tar=${SGR[archive]}' '*.gz=${SGR[archive]}'
  '*.tgz=${SGR[archive]}' '*.bz2=${SGR[archive]}' '*.xz=${SGR[archive]}'
  '*.zst=${SGR[archive]}' '*.7z=${SGR[archive]}' '*.rar=${SGR[archive]}'
  '*.dmg=${SGR[archive]}' '*.pkg=${SGR[archive]}'

  # secrets — the alert hue, so a stray key is visible at a glance
  '*.pem=${SGR[alert]}' '*.key=${SGR[alert]}' '*.p12=${SGR[alert]}'
  '*.env=${SGR[alert]}' '.env=${SGR[alert]}'

  # generated / machine-owned — recessive; you don't edit these
  '*.lock=${SGR[quiet]}' '*.sum=${SGR[quiet]}' '*.min.js=${SGR[quiet]}'
  '*.map=${SGR[quiet]}' '*.pyc=${SGR[rule]}' '*.o=${SGR[rule]}'
  '*.bak=${SGR[rule]}' '*.log=${SGR[quiet]}'
)
_eza_ext=( ${(e)_eza_ext} )   # the entries above are written with ${SGR[...]} unexpanded for readability; resolve them now
export EZA_COLORS="${(j.:.)_eza}:${(j.:.)_eza_ext}"
unset _eza _eza_ext

# --- LS_COLORS (completion menu) ---------------------------------------
typeset -a _ls=(
  "di=1;${SGR[dir]}" "ln=${SGR[link]}" "or=${SGR[alert]}" "ex=1;${SGR[exe]}"
  "fi=${SGR[ink]}" "pi=${SGR[special]}" "so=${SGR[special]}"
  "bd=${SGR[special]}" "cd=${SGR[special]}" "su=1;${SGR[setid]}" "sg=1;${SGR[setid]}"
  "tw=${SGR[dir]}" "ow=${SGR[dir]}" "st=${SGR[dir]}"
)
export LS_COLORS="${(j.:.)_ls}"
unset _ls
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format "%F{${ZC[muted]}}%d%f"
zstyle ':completion:*:messages'     format "%F{${ZC[muted]}}%d%f"
zstyle ':completion:*:warnings'     format "%F{${ZC[alert]}}no match%f"
zstyle ':completion:*:corrections'  format "%F{${ZC[g_mod]}}%d (errors: %e)%f"

# --- fzf ----------------------------------------------------------------
export FZF_DEFAULT_OPTS="
  --height=45% --layout=reverse --border=none --info=inline
  --color=fg:${ZC[ink2]},fg+:${ZC[ink]},bg:-1,bg+:${ZC[selbg]}
  --color=hl:${ZC[g_mod]},hl+:${ZC[g_mod]}
  --color=info:${ZC[quiet]},prompt:${ZC[link]},pointer:${ZC[alert]}
  --color=marker:${ZC[exe]},spinner:${ZC[special]},header:${ZC[muted]}
  --color=border:${ZC[rule]},gutter:-1"

# --- zsh-syntax-highlighting ---------------------------------------------
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=${ZC[ink]}"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${ZC[alert]},bold"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${ZC[special]}"
ZSH_HIGHLIGHT_STYLES[alias]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[function]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[command]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=${ZC[exe]},italic"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=${ZC[rule]}"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=${ZC[exe]}"
ZSH_HIGHLIGHT_STYLES[path]="fg=${ZC[dir]}"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=${ZC[rule]}"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=${ZC[dir]}"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=${ZC[g_mod]}"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=${ZC[special]}"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${ZC[link]}"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${ZC[link]}"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=${ZC[special]}"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${ZC[archive]}"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${ZC[archive]}"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${ZC[archive]}"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=${ZC[media]}"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=${ZC[media]}"
ZSH_HIGHLIGHT_STYLES[assign]="fg=${ZC[media]}"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=${ZC[g_mod]}"
ZSH_HIGHLIGHT_STYLES[comment]="fg=${ZC[quiet]}"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=${ZC[muted]}"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=${ZC[exe]}"

# --- zsh-autosuggestions ---------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${ZC[quiet]}"

# --- bat ------------------------------------------------------------------
export BAT_THEME='OneHalfDark'   # nearest bundled match to the #282c34 ground
