# prompt.zsh — the prompt, and nothing else.
#
# Standalone by design: this file defines its own colors instead of reading
# ZC[] from colors.zsh, so it can be dropped into any zsh with no other
# dependency. The hexes below are still the palette's values (solved in OKLCH
# against a #282c34 ground), just copied in rather than looked up.
#
#   left    ~/parent/path in dir-blue, current folder brighter and bold, then ❯
#   right   elapsed time · exit status · clock, all 12-hour am/pm
#
# Sourced from .zshrc.

zmodload zsh/datetime   # $EPOCHREALTIME — sub-second resolution, unlike $SECONDS
autoload -Uz add-zsh-hook

# --- Colors ---
# Truecolor when the terminal advertises it, the nearest xterm-256 index
# otherwise, so this degrades gracefully over ssh or a plain TERM.
if [[ $COLORTERM == (truecolor|24bit) || $TERM == *(24bit|direct)* ]]; then
  typeset -g _p_parent='#afcbff'   # folders above the current one
  typeset -g _p_leaf='#6ad9ee'     # the folder you're in — brighter, bold
  typeset -g _p_ok='#84e193'       # ✓ and the caret after a success
  typeset -g _p_err='#ffa9a1'      # ✘ and the caret after a failure
  typeset -g _p_dim='#878888'      # duration and clock — metadata, muted on purpose
else
  typeset -g _p_parent=153 _p_leaf=117 _p_ok=114 _p_err=217 _p_dim=245
fi

# --- Icons ---
# Literal Nerd Font private-use glyphs, not $'\uXXXX' escapes — those fail with
# "character not in range" wherever the locale isn't UTF-8 (bare ssh, cron).
# Apple Terminal ships no patched font and would draw tofu, so it goes without.
# ✓ and ✘ are ordinary Unicode and render everywhere, so they stay in both.
case "$TERM_PROGRAM" in
  Apple_Terminal) typeset -g _p_i_dur='' _p_i_time='' ;;
  *)              typeset -g _p_i_dur=' ' _p_i_time=' ' ;;
esac

PROMPT_MIN_DURATION=0.2   # below this the number is just shell overhead, not information

typeset -gF _p_start=0

_p_duration() {   # float seconds -> 1.4s / 2m 04s / 1h 02m
  local -F s=$1
  (( s < 60 )) && { printf '%.1fs' $s; return }
  local -i t=$s   # an integer-typed assignment truncates; int() would need zsh/mathfunc
  (( t < 3600 )) \
    && printf '%dm %02ds' $(( t / 60 ))   $(( t % 60 )) \
    || printf '%dh %02dm' $(( t / 3600 )) $(( t % 3600 / 60 ))
}

_p_preexec() { _p_start=$EPOCHREALTIME }

_p_precmd() {
  local code=$?   # has to be read before anything else runs

  # Split the path so only the directory you're actually in gets the bright hue.
  # The %(5~...) ternary truncates first; ${(%)} then expands it to real text.
  local path_disp=${(%):-'%(5~|%-1~/…/%3~|%~)'}
  local parent='' leaf=$path_disp
  [[ $path_disp == */* ]] && { parent=${path_disp%/*}/ leaf=${path_disp##*/} }

  PROMPT="%F{$_p_parent}${parent}%f%F{$_p_leaf}%B${leaf}%b%f "
  (( code == 0 )) \
    && PROMPT+="%F{$_p_ok}❯%f " \
    || PROMPT+="%F{$_p_err}❯%f "

  local -a segs   # joined with exactly one space, so a missing segment leaves no gap

  if (( _p_start )); then
    local -F elapsed=$(( EPOCHREALTIME - _p_start ))
    (( elapsed > PROMPT_MIN_DURATION )) && segs+=( "%F{$_p_dim}${_p_i_dur}$(_p_duration $elapsed)%f" )
    _p_start=0
  fi

  (( code == 0 )) \
    && segs+=( "%F{$_p_ok}✓%f" ) \
    || segs+=( "%F{$_p_err}✘ $code%f" )

  local clock=${${(%):-%D{%l:%M %p}}## }   # %l space-pads single digits; drop the pad
  segs+=( "%F{$_p_dim}${_p_i_time}${clock}%f" )

  RPROMPT="${(j: :)segs}"
}

add-zsh-hook preexec _p_preexec
add-zsh-hook precmd  _p_precmd
