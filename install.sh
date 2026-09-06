#!/usr/bin/env bash
#
# Link this repo into place.
#
#   ./install.sh              link everything
#   ./install.sh --dry-run    show what would happen, touch nothing
#   ./install.sh --unlink     remove links this repo owns, restore backups
#
# Symlinks rather than copies: editing a file in the repo takes effect in the
# next shell, with no sync step to forget. Anything already in the way is moved
# to a timestamped backup directory, never overwritten.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY=0; UNLINK=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --unlink)  UNLINK=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

say()  { printf '  %s\n' "$*"; }
run()  { if (( DRY )); then say "would: $*"; else "$@"; fi; }

# link <source-in-repo> <destination>
link() {
  local src="$REPO/$1" dst="$2"
  if [[ ! -e $src ]]; then
    say "skip (missing in repo): $1"
    return
  fi
  if [[ -L $dst ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    say "ok:   ${dst/#$HOME/~}"
    return
  fi
  if [[ -e $dst || -L $dst ]]; then
    run mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
    run mv "$dst" "$BACKUP/${dst#$HOME/}"
    say "backed up: ${dst/#$HOME/~}"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  say "link: ${dst/#$HOME/~}  ->  $1"
}

unlink_one() {
  local src="$REPO/$1" dst="$2"
  if [[ -L $dst ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    run rm "$dst"
    say "unlinked: ${dst/#$HOME/~}"
  fi
}

# The complete map from repo path to destination. `home/` lands in $HOME,
# `config/` in $XDG_CONFIG_HOME. Add a line here when you add a config.
declare -a MAP=(
  "home/.zshenv|$HOME/.zshenv"
  "config/zsh/.zshrc|$XDG_CONFIG_HOME/zsh/.zshrc"
  "config/zsh/.zprofile|$XDG_CONFIG_HOME/zsh/.zprofile"
  "config/zsh/.p10k.zsh|$XDG_CONFIG_HOME/zsh/.p10k.zsh"
  "config/ghostty/config|$XDG_CONFIG_HOME/ghostty/config"
  "config/ripgrep/config|$XDG_CONFIG_HOME/ripgrep/config"
)

if (( UNLINK )); then
  echo "Removing links owned by $REPO"
  for entry in "${MAP[@]}"; do unlink_one "${entry%%|*}" "${entry#*|}"; done
  echo
  echo "Backups, if any, are under ~/.dotfiles-backup/ — restore by hand."
  exit 0
fi

(( DRY )) && echo "DRY RUN — nothing will be written." && echo

echo "Linking:"
for entry in "${MAP[@]}"; do link "${entry%%|*}" "${entry#*|}"; done

# Directories the shell writes into. Creating them here means the first
# interactive shell never has to, and never fails quietly if it cannot.
echo
echo "State and cache directories:"
for d in "$XDG_STATE_HOME/zsh" "$XDG_STATE_HOME/less" "$XDG_STATE_HOME/node" \
         "$XDG_STATE_HOME/python" "$XDG_STATE_HOME/sqlite" "$XDG_CACHE_HOME/zsh"; do
  if [[ -d $d ]]; then say "ok:   ${d/#$HOME/~}"; else run mkdir -p "$d"; say "made: ${d/#$HOME/~}"; fi
done

echo
if [[ -d $BACKUP ]]; then echo "Replaced files were saved to ${BACKUP/#$HOME/~}"; echo; fi
echo "Done. Start a new shell:  exec zsh"
