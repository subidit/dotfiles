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
Not `source .zshrc` — that only adds/overwrites what's in the file, it won't clear stray functions or options you toggled by hand this session. `exec zsh` starts a genuinely clean process.

## Relocate a tool's cache/config out of `$HOME`

Check what env var the tool actually reads (don't assume) — usually `XDG_CACHE_HOME` or a tool-specific `*_CONFIG_FILE`/`*_CACHE_DIR`. Set it in `.zshenv` if it needs to apply to every shell:
```zsh
export XDG_CACHE_HOME="$ZDOTDIR/cache"
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

## Generate a separate P10k config without overwriting the default

```zsh
POWERLEVEL9K_CONFIG_FILE=$ZDOTDIR/.p10k-name.zsh p10k configure
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
