# ~/.config/zsh/.p10k-custom.zsh
#
# Customizations that survive `p10k configure` regenerating .p10k.zsh.
# Sourced after .p10k.zsh in .zshrc so these overrides take precedence.

# --- Directory icon customizations ----------------------------------------
# For ~/Developer and its subdirectories, show a hammer instead of a folder.
# Uses Nerd Font glyph (fa-hammer, U+EEFF), which inherits the segment's
# text color rather than rendering as a fixed-color pictograph.
typeset -g POWERLEVEL9K_DIR_CLASSES=(
  '~/Developer(|/*)'  DEV      ''
  '*'                 DEFAULT  '')
typeset -g POWERLEVEL9K_DIR_DEV_VISUAL_IDENTIFIER_EXPANSION=''

# --- 24-bit OKLCH-tuned palette overrides ---------------------------------
# Solved against the #282c34 ground for target APCA contrast (Lc).

# Directory segment: pastel blue ground with high-contrast navy text tiers
typeset -g POWERLEVEL9K_DIR_BACKGROUND='#9ac9fa'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#1d2a37'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#434e5b'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#091725'

# Time segment: warm sand/cream background
typeset -g POWERLEVEL9K_TIME_BACKGROUND='#e5ddd1'
