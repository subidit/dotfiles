# How-to guides

Goal-oriented. You know what you want; here's how.

## Test a shell option before committing to it

```zsh
[[ -o OPTION_NAME ]] && echo ON || echo OFF   # check current state
setopt OPTION_NAME       # try it, this-session-only
unsetopt OPTION_NAME     # revert
```
Only add it to `.zshrc` once you've confirmed it does what you expect live.

## Check if a `setopt` is even a default already

```zsh
zsh -f -c '[[ -o OPTION_NAME ]] && echo ON || echo OFF'
```
`-f` skips all rc files. If it's already `ON`, adding it to `.zshrc` is a no-op.

## Find what raw bytes a key actually sends

```zsh
cat -v
# press the key, read the output, Ctrl-C to exit
```
Don't guess a key sequence (`^[[A` vs `^[OA` vs `^[b`) — terminals disagree, and `$key[...]`/terminfo lookups can be empty or wrong. This is ground truth.

## Bind a key

```zsh
bindkey 'KEYSEQ' widget-name      # existing widget
autoload -Uz some-function
zle -N widget-name some-function  # custom function → needs this before bindkey can target it
bindkey 'KEYSEQ' widget-name
```

## Reload config after an edit

```zsh
exec zsh
```
Not `source .zshrc` — that only adds/overwrites what's in the file, it won't clear stray functions or options you toggled by hand this session. `exec zsh` starts a genuinely clean process. Aliased to `zr`.

## See the prompt without opening a new shell

```zsh
_p_precmd; print -rP -- "$PROMPT"; print -rP -- "$RPROMPT"
```
`precmd` normally runs between commands, so calling it by hand then printing with `print -rP` (prompt expansion) shows exactly what you'd get. To test a specific state, set the inputs first:

```zsh
_p_start=$(( EPOCHREALTIME - 75 )); (exit 127); _p_precmd   # a 1m15s command that failed
```

## Change the prompt's duration floor or drop its glyphs

```zsh
PROMPT_MIN_DURATION=2    # only report commands slower than 2s
PROMPT_POWERLINE=0       # no Nerd Font glyphs — set it BEFORE prompt.zsh is sourced
```
Both live at the top of `prompt.zsh`. `PROMPT_POWERLINE` has to be set before the file runs, since it only picks a default when the variable doesn't already exist.

## See what everything looks like without the palette

```zsh
d=~/.config/cache/zsh-nocolors; mkdir -p $d \
  && sed '/\/colors\.zsh/d' ~/.config/zsh/.zshrc > $d/.zshrc \
  && cp ~/.config/zsh/prompt.zsh $d/ \
  && env -u EZA_COLORS -u LS_COLORS -u FZF_DEFAULT_OPTS -u BAT_THEME ZDOTDIR=$d zsh
```
A throwaway shell with `colors.zsh` skipped; `exit` returns. The `env -u` matters — those four are exported, so a nested shell would otherwise inherit the styled values and the test would lie. (`ZSH_HIGHLIGHT_STYLES` isn't exported, so it resets by itself.) The prompt survives, because `prompt.zsh` doesn't read the palette.

## Add a filename color for a new extension

In `colors.zsh`, add to the `_eza_ext` array, using an existing `SGR` key rather than a raw escape:

```zsh
'*.nix=${SGR[g_mod]}'    # config category
```
Single quotes are deliberate — the entries are expanded in one pass on the line below the array. Pick the key by category, not by "what looks nice": that's the file's whole rule.

## Look up what a palette key actually is

```zsh
print -rl -- ${(kv)PAL} | paste - -   # name → hex
print -r -- $SGR[exe]                 # name → escape parameters
```

## Time your shell startup

```zsh
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit; done 2>&1 | grep real
```
Ignore the first run — it's a cold cache. To find what's slow, time the suspects individually:

```zsh
/usr/bin/time -p zsh -f -c 'autoload -Uz compinit; compinit'
```

## Time a single prompt render

```zsh
zmodload zsh/datetime
t=$EPOCHREALTIME; repeat 20 _p_precmd; print $(( (EPOCHREALTIME - t) * 50 ))   # ms per prompt
```
Anything over ~20 ms is felt as lag between commands. A `$(...)` in `precmd` is a subshell fork every prompt; `git` anything is a real process.

## Relocate a tool's cache/config out of `$HOME`

Check what env var the tool actually reads (don't assume) — usually `XDG_CACHE_HOME` or a tool-specific `*_CONFIG_FILE`/`*_CACHE_DIR`. Set it in `.zshenv` if it needs to apply to every shell:
```zsh
export XDG_CACHE_HOME="$HOME/.config/cache"
```
Won't work for GUI apps launched from Dock/Spotlight — those don't inherit `.zshenv` at all (only shell-launched processes do). For those, check the app's own settings/config file instead.

## Make something behave differently per terminal app

```zsh
case "$TERM_PROGRAM" in
  vscode)         ... ;;
  Apple_Terminal) ... ;;
  ghostty)        ... ;;
  *)              ... ;;   # always keep a fallback
esac
```
Verify the real value first — `echo $TERM_PROGRAM` in the actual app, or check the terminal's source. Don't guess.

## Use a Unicode character in a prompt or config

Paste the literal character. Don't use `$'\uXXXX'`:

```zsh
typeset -g icon=$' '   # "character not in range" wherever the locale isn't UTF-8
typeset -g icon=' '         # works everywhere
```
Check what landed in the file afterwards:
```zsh
python3 -c "print(sorted({hex(ord(c)) for c in open('FILE').read() if ord(c) > 0x2700}))"
```

## Pick a Nerd Font variant

Use the `Mono` build for terminals and code editors — the base/`Propo` builds have icon glyphs wider than one monospace cell, which misaligns tables. Get the exact registered family name before configuring anything:
```zsh
pip3 install fonttools
python3 -c "
from fontTools.ttLib import TTFont
t = TTFont('/path/to/Font-Regular.ttf')
print({r.nameID: r.toUnicode() for r in t['name'].names if r.nameID in (1,4,16)})
"
```

## Check if an env-var change actually took effect

Open a **new** terminal tab, or `exec zsh`. An already-open shell doesn't re-read `.zshenv`/`.zshrc` just because you edited them.
