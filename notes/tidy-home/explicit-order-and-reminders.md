---
name: explicit-order-and-reminders
description: "In tidy-home steps and docs, spell out the order of events, create target folders first, and remind the user to open a new Ghostty tab"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 220507be-49d4-4c8b-abc4-12bbe094097a
  modified: 2026-10-24T17:05:36.213Z
---

Every step I give (and every step written into the guide) must state its order explicitly and end with a clear "what to do next", including reminders like "open a new Ghostty tab so ~/.zshenv takes effect", "quit the app before moving its folder", "set the variable before first run".

Standard order for a relocation variable (confirmed with PYTHON_HISTORY, 2026-10-24):
1. add the `export` to `~/.zshenv`
2. **create the target folder** (`mkdir -p`) — some tools silently do nothing if it's missing (Python drops REPL history without an error; Codex needs `~/.config/codex` to exist)
3. open a **new Ghostty tab** (⌘T); old tabs keep the old environment
4. check with `echo $VAR`
5. only then run the tool, and check `ls -A ~`

The user explicitly asked me to remember the order and the folder creation.

Gotcha: commands the user runs through the `!` box in the Claude app run in a shell started before their edits, like an old tab, and can't run interactive prompts. For "new tab" checks and REPL tests, send them to a real Ghostty tab. My own Bash calls start a fresh zsh and do see `~/.zshenv` changes.

**Why:** the user found that the order of events mattered a lot in the clean-home work (variables set too late, old terminal tabs keeping old values, apps reopened at login before setup).

**How to apply:** structure each step as Before → Do → Expected → Next, and put the folder-creation and new-tab reminders in the Do/Next lines, not buried in prose.
