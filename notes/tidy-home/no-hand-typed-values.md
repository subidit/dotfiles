---
name: no-hand-typed-values
description: "In docs, give a command that prints or copies the exact value instead of /Users/<you>-style placeholders"
metadata:
  node_type: memory
  type: feedback
  originSessionId: fab850d0-002f-4841-ae65-c679e9ebf06f
  modified: 2026-10-25T16:28:55.616Z
---

In tutorial and how-to steps, never ask the reader to work out or retype a value like `/Users/<you>/.config/claude`. Give a command that prints it (`print -D $VAR` shows `~/...`, identical on every Mac) or copies it (`print -rn -- $VAR | pbcopy`, then paste). Use a `<placeholder>` only when the value truly can't be fetched (e.g. choosing a gcloud project), and then show the full command with the placeholder, plus a command that lists the choices; later steps read it back (`gcloud config get-value project`).

**Why:** the user asked for this on 2026-10-25 after seeing the Claude app's `CLAUDE_CONFIG_DIR` step; typed paths invite typos, and the VM has no shared clipboard.

**How to apply:** every Expected line and every value to paste into an app or prompt. Test the command's output before writing it into the doc. Related: [[explicit-order-and-reminders]].
