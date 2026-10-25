#!/bin/zsh -f
# Read-only snapshot of the VM's home folder for the tidy-home test run.
# Usage, in the VM's Terminal:  zsh <this file> <step>
# Writes only out-<step>.txt next to this script. -f: reads no zsh startup
# files, so the variables shown are exactly the ones the calling tab has.
# Prints file names, never file contents or the full environment.

step=${1:-snapshot}
out="${0:A:h}/out-$step.txt"

{
  print "## step $step, $(date '+%F %T'), macOS $(sw_vers -productVersion)"

  print "\n## ls -A ~"
  ls -A ~

  print "\n## variables in this tab"
  for v in ZDOTDIR XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME \
           PYTHON_HISTORY NODE_REPL_HISTORY npm_config_cache npm_config_userconfig \
           CLAUDE_CONFIG_DIR COPILOT_HOME PI_CODING_AGENT_DIR VSCODE_PORTABLE \
           MPLCONFIGDIR IPYTHONDIR JUPYTER_CONFIG_DIR KERAS_HOME NLTK_DATA RUSTUP_HOME \
           CODEX_HOME DSH_HOME DSH_AGENTS_HOME EDITOR; do
    print "$v=${(P)v-unset}"
  done

  print "\n## ~/.config ~/.local ~/.cache ~/.codex ~/.dsh ~/.agents (3 levels, names only)"
  find ~/.config ~/.local ~/.cache ~/.codex ~/.dsh ~/.agents -maxdepth 3 2>/dev/null \
    | sed "s|^$HOME|~|" | sort

  print "\n## links"
  for l in ~/.config/zsh/.zshenv /Applications/code-portable-data; do
    [[ -L $l ]] && print "$l -> $(readlink $l)" || print "$l: not a link"
  done

  print "\n## ~/Library spots that should or shouldn't exist"
  for d in "Application Support/Code" "Application Support/zoxide" "Jupyter"; do
    [[ -e ~/Library/$d ]] && print "exists: ~/Library/$d" || print "absent: ~/Library/$d"
  done

  print "\n## ~/.Trash (names only; may need Full Disk Access)"
  ls -A ~/.Trash 2>&1

  print "\n## commands"
  for c in brew git gh node npm python3 uv fzf zoxide micro claude codex dsh opencode pi gcloud; do
    print "$c: ${commands[$c]:--}"
  done

  print "\n## macOS zsh startup lines"
  grep -n -E 'HISTFILE|SHELL_SESSION' /etc/zshrc /etc/zshrc_Apple_Terminal 2>&1
} >| "$out" 2>&1

print "saved: $out"
