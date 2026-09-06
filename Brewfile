# Everything this configuration expects to find.
#   brew bundle install --file=Brewfile
#
# Deliberately narrow: this is the dependency list for the dotfiles, not a
# dump of every package on the machine.

tap "romkatv/powerlevel10k"

# --- shell ---------------------------------------------------------------
brew "powerlevel10k"              # prompt, with instant-prompt support
brew "zsh-autosuggestions"        # inline suggestion from history
brew "zsh-syntax-highlighting"    # command-line syntax colouring

# --- the coreutils replacements the aliases point at ----------------------
brew "eza"                        # ls; drives the colour system
brew "bat"                        # cat, and $MANPAGER
brew "fd"                         # find; feeds fzf
brew "ripgrep"                    # grep (NOT aliased over grep — see docs)
brew "fzf"                        # fuzzy finder, ^T / ^R / alt-C
brew "zoxide"                     # frecency-ranked cd

# --- editor --------------------------------------------------------------
brew "fresh-editor"               # $EDITOR / $VISUAL; terminal-native, blocks

# --- terminal and typeface -----------------------------------------------
cask "ghostty"
cask "font-jetbrains-mono"        # the text face
cask "font-symbols-only-nerd-font" # icon fallback only; keeps ligatures intact
