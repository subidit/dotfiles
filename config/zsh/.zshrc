# $ZDOTDIR/.zshrc — interactive shell.
#
# Colour model: every colour below is solved in OKLCH against Ghostty's
# #282c34 ground for a target APCA contrast (Lc), then converted to sRGB.
# Two rules hold the system together:
#   1. LIGHTNESS carries hierarchy. Five neutral tiers, Lc 78/62/48/34/26.
#      Nothing that must be read sits below Lc 30.
#   2. HUE carries category, never rank. Where a scale must be *ordered*
#      (file size), lightness is held constant at Lc 60 and the ordering is
#      carried by hue + chroma instead — because every step of that scale is
#      a number you have to read, so no step may be dimmer than another.

# Powerlevel10k instant prompt. Anything that may print or prompt goes above.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Shell options --------------------------------------------------------
setopt AUTO_CD              # bare directory name cds into it
setopt AUTO_PARAM_SLASH     # trailing slash when completing a directory
setopt EXTENDED_GLOB
setopt GLOB_DOTS            # globs see dotfiles without a literal leading dot
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt INTERACTIVE_COMMENTS
setopt CORRECT              # spelling correction for command words
setopt NO_BEEP
setopt RM_STAR_WAIT         # GLOB_DOTS makes `rm *` wider than it looks; pause first
unsetopt PROMPT_SP          # no leading newline; trades away partial-line preservation

# Directory stack: every cd is pushd, so `cd -<TAB>` is a visited-dirs menu.
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
DIRSTACKSIZE=20

# --- History --------------------------------------------------------------
# History is *state*, not config, so it belongs in XDG_STATE_HOME rather than
# next to the rc files.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=200000             # in-memory; must exceed SAVEHIST for dedup to work
SAVEHIST=100000             # on-disk
setopt EXTENDED_HISTORY     # record timestamp + duration
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt HIST_VERIFY          # expand !! and show it before running
setopt SHARE_HISTORY        # implies INC_APPEND_HISTORY

# --- Completion -----------------------------------------------------------
zmodload zsh/complist
autoload -Uz compinit
_comp_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d ${_comp_dump:h} ]] || mkdir -p ${_comp_dump:h}
if [[ -n $_comp_dump(#qN.mh+24) ]]; then
  compinit -d "$_comp_dump"          # stale: rebuild
else
  compinit -C -d "$_comp_dump"       # fresh: trust the cache, skip the scan
fi
unset _comp_dump
setopt AUTO_MENU            # a second TAB opens the menu
setopt COMPLETE_IN_WORD ALWAYS_TO_END
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# --- Palette --------------------------------------------------------------
# Single source of truth. Every consumer below (eza, completion menus, fzf,
# syntax highlighting, autosuggestions) is derived from this table, so the
# window holds one colour system instead of four unrelated ones.
#
#   role        hex      Lc   hue   note
typeset -gA PAL=(
  # neutral hierarchy — lightness is the only variable
  ink        d7d7d7   # 78  --   primary text: filenames, headers
  ink2       bcbcbc   # 62  --   secondary
  muted      a2a3a2   # 48  --   metadata
  quiet      878888   # 34  --   deliberately recessive; still legible
  rule       777777   # 26  --   punctuation and rules; the floor

  # filename categories — eight hues, minimum separation dE2000 = 10.6.
  # Kept to eight on purpose: icons already encode fine-grained file type,
  # so colour carries structural class and does not duplicate the glyph.
  dir        afcbff   # 70  263
  link       6ad9ee   # 70  212
  linkpath   78aabd   # 48  224   the *target*, recessed a tier from the link
  exe        84e193   # 72  148
  archive    ffb773   # 68   63
  alert      ffa9a1   # 64   25   broken links, keys, certificates
  media      ffa6e5   # 66  338
  special    c4b6ff   # 64  293   sockets, fifos, devices, mount points

  # permission bits — hue = which bit, lightness = whose bit.
  # Position in `rwxr-xr-x` already tells you user/group/other, so the tiers
  # only have to be *ordered*, not individually identifiable.
  r_u        76d2f4   # 68  224
  r_g        77b3ca   # 52  224
  r_o        719aaa   # 40  224
  w_u        e7c264   # 68   88
  w_g        c1a86a   # 52   88
  w_o        a39269   # 40   88
  x_u        8ad896   # 68  148
  x_g        83b789   # 52  148
  x_o        789c7c   # 40  148
  setid      ffb4aa   # 68   27   setuid/setgid/sticky

  # ownership
  you        73cff1   # 66  224   you; the only owner colour that should pop
  root       ffa499   # 62   27
  grp        86a7be   # 48  239

  # git
  g_add      7ad789   # 66  148
  g_mod      e9be49   # 66   88
  g_del      ffa498   # 62   28
  g_ren      68cff5   # 66  225
  g_typ      c3b1fe   # 62  295
  g_con      ffc2b9   # 74   29
  b_clean    87b58d   # 52  148
  b_dirty    d6b561   # 60   88

  # file-size scale — iso-lightness at Lc 60, ordered by hue + chroma
  n_b        a1bbdc   # 60  255   < 1 KB
  n_k        7ac5c3   # 60  193
  n_m        8bc793   # 60  148
  n_g        d8b45c   # 60   88
  n_t        ffa25d   # 60   55   >= 1 TB
  # the unit suffix, one tier down, same hue: "4.3" reads before "MB"
  u_b        8b9db4   # 44  255
  u_k        73a4a2   # 44  193
  u_m        7da582   # 44  148
  u_g        b09960   # 44   88
  u_t        cc8d60   # 44   55

  date       9aa8b9   # 50  253
  selbg      41464f   #  -- 264   ground lifted 1.34x in OKLCH L, hue held
)

# Compile the palette to SGR parameters once, at startup.
# 24-bit when the terminal advertises it; otherwise quantised to the xterm-256
# cube so the same design degrades gracefully over ssh or a plain TERM.
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

# zle/prompt escapes take a different spelling than raw SGR, and zsh will
# happily emit 24-bit codes there even on a terminal that cannot render them.
# Mirror the table into that spelling so it degrades with everything else.
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

# --- eza ------------------------------------------------------------------
typeset -a _eza=(
  # structure
  "di=1;${SGR[dir]}" "ln=${SGR[link]}" "lp=${SGR[linkpath]}" "or=${SGR[alert]}"
  "ex=1;${SGR[exe]}" "fi=${SGR[ink]}"
  "pi=${SGR[special]}" "so=${SGR[special]}" "bd=${SGR[special]}" "cd=${SGR[special]}"
  "sp=${SGR[special]}" "mp=${SGR[special]}" "bO=${SGR[alert]}"
  # permissions: vertical colour bands you can scan without reading letters
  "ur=${SGR[r_u]}" "uw=${SGR[w_u]}" "ux=${SGR[x_u]}" "ue=${SGR[x_u]}"
  "gr=${SGR[r_g]}" "gw=${SGR[w_g]}" "gx=${SGR[x_g]}"
  "tr=${SGR[r_o]}" "tw=${SGR[w_o]}" "tx=${SGR[x_o]}"
  "su=1;${SGR[setid]}" "sf=1;${SGR[setid]}" "oc=${SGR[muted]}" "xa=${SGR[linkpath]}"
  # ownership — only "you" is allowed to pop
  "uu=1;${SGR[you]}" "uR=1;${SGR[root]}" "un=${SGR[quiet]}"
  "gu=${SGR[grp]}"   "gR=${SGR[root]}"   "gn=${SGR[quiet]}"
  # size: number at Lc 60, unit at Lc 44, hue climbing with magnitude
  "nb=${SGR[n_b]}" "nk=${SGR[n_k]}" "nm=${SGR[n_m]}" "ng=${SGR[n_g]}" "nt=${SGR[n_t]}"
  "ub=${SGR[u_b]}" "uk=${SGR[u_k]}" "um=${SGR[u_m]}" "ug=${SGR[u_g]}" "ut=${SGR[u_t]}"
  # git
  "ga=${SGR[g_add]}" "gm=${SGR[g_mod]}" "gd=${SGR[g_del]}" "gv=${SGR[g_ren]}"
  "gt=${SGR[g_typ]}" "gi=${SGR[quiet]}" "gc=1;${SGR[g_con]}"
  "Gm=1;${SGR[exe]}" "Go=${SGR[dir]}" "Gc=${SGR[b_clean]}" "Gd=${SGR[b_dirty]}"
  # metadata + UI
  "da=${SGR[date]}" "in=${SGR[quiet]}" "bl=${SGR[quiet]}"
  "lc=${SGR[quiet]}" "lm=${SGR[w_u]}" "df=${SGR[archive]}" "ds=${SGR[archive]}"
  "cc=${SGR[alert]}"
  "xx=${SGR[rule]}"          # was Lc 0.0 — literally invisible on this ground
  "hd=1;${SGR[ink]}"         # bold, not underlined: the rule clipped descenders
  # file-kind accents, kept few
  "im=${SGR[media]}" "vi=${SGR[media]}" "mu=${SGR[media]}" "lo=${SGR[media]}"
  "cr=${SGR[alert]}" "co=${SGR[archive]}" "bu=${SGR[archive]}"
  "tm=${SGR[quiet]}" "cm=${SGR[quiet]}" "do=${SGR[ink]}" "sc=${SGR[ink]}"
)
export EZA_COLORS="${(j.:.)_eza}"
unset _eza

# --- LS_COLORS ------------------------------------------------------------
# This was never set, which silently made the completion `list-colors` zstyle
# a no-op: the completion menu had no colours at all. Derived from the same
# palette so a directory looks identical in `ls` and in the TAB menu.
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

# --- fzf ------------------------------------------------------------------
export FZF_DEFAULT_OPTS="
  --height=45% --layout=reverse --border=none --info=inline
  --color=fg:${ZC[ink2]},fg+:${ZC[ink]},bg:-1,bg+:${ZC[selbg]}
  --color=hl:${ZC[g_mod]},hl+:${ZC[g_mod]}
  --color=info:${ZC[quiet]},prompt:${ZC[link]},pointer:${ZC[alert]}
  --color=marker:${ZC[exe]},spinner:${ZC[special]},header:${ZC[muted]}
  --color=border:${ZC[rule]},gutter:-1"

# --- zsh-syntax-highlighting styles --------------------------------------
# Defaults use the 16 ANSI colours, i.e. a second, unrelated palette in the
# same window. Bound to the table above instead.
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

# Autosuggestions: speculative text, so it sits at the recessive tier —
# clearly present, clearly not yet yours. The default (fg=8, Lc ~17) is below
# the threshold where you can read it without leaning in.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${ZC[quiet]}"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# --- Key bindings ---------------------------------------------------------
# Word motions should stop at path separators, so alt-left walks a path
# component at a time. Default WORDCHARS swallows the whole path.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Prefix history search that also parks the cursor at end of line; the plain
# widgets leave it where it was, which reads as a glitch mid-recall.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
bindkey '^P'   history-beginning-search-backward-end
bindkey '^N'   history-beginning-search-forward-end

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;3D' backward-word      # alt + left
bindkey '^[[1;3C' forward-word       # alt + right
bindkey '^[[1;5D' backward-word      # ctrl + left
bindkey '^[[1;5C' forward-word       # ctrl + right
bindkey '^[^?'   backward-kill-word  # alt + backspace
bindkey '^U'     backward-kill-line  # kill to start, not the whole line

# ^X^E: open the current command line in $EDITOR, save to run it.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# In the completion menu, hjkl navigates and enter accepts.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# --- Pager and man --------------------------------------------------------
export LESS='-R -F -X -i -M --mouse --wheel-lines=3'
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"
  export MANROFFOPT='-c'
  export BAT_THEME='OneHalfDark'   # nearest match to the #282c34 ground
fi

# --- Aliases --------------------------------------------------------------
# --color-scale-mode=fixed is what makes the five designed size colours apply;
# the default (gradient) interpolates in RGB and ignores nb/nk/nm/ng/nt.
_eza_base=(--color=always --icons=always --group-directories-first)
alias ls="eza ${_eza_base}"
alias ll="eza ${_eza_base} -l --git --smart-group --time-style=long-iso --color-scale=size --color-scale-mode=fixed"
alias la="eza ${_eza_base} -la --git --smart-group --time-style=long-iso --color-scale=size --color-scale-mode=fixed"
alias lt="eza ${_eza_base} --tree --level=2 --git-ignore"
alias lta="eza ${_eza_base} --tree --git-ignore"
unset _eza_base

# --style=plain keeps line numbers and the header out, so `cat` output stays
# copy-pasteable and diffable. `bat` itself is still there when you want the
# full furniture.
alias cat='bat --paging=never --style=plain'

# NOTE: `alias grep=rg` was removed. rg is not a grep: it skips hidden files
# and anything gitignored by default, so `grep` would silently report no match
# on files that do contain the pattern. rg is already one keystroke shorter.
alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias d='dirs -v'

# --- Tools ----------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

for _f in completion key-bindings; do
  [[ -f /opt/homebrew/opt/fzf/shell/$_f.zsh ]] && source /opt/homebrew/opt/fzf/shell/$_f.zsh
done
unset _f

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
  # fzf picks _fzf_compgen_dir for cd/pushd/rmdir and _fzf_compgen_path
  # otherwise, so overriding both makes `vim **<TAB>` fast and gitignore-aware.
  _fzf_compgen_path() { fd --hidden --exclude .git . "$1" | sed 's@^\./@@'; }
  _fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1" | sed 's@^\./@@'; }
fi
command -v bat >/dev/null 2>&1 && \
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

_gcloud=/opt/homebrew/Caskroom/gcloud-cli/latest/google-cloud-sdk
[[ -f $_gcloud/path.zsh.inc ]] && source $_gcloud/path.zsh.inc
[[ -f $_gcloud/completion.zsh.inc ]] && source $_gcloud/completion.zsh.inc
unset _gcloud

# --- Prompt and plugins (order matters) -----------------------------------
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh

[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# must stay last
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
