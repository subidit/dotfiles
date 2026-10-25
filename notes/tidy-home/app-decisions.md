---
name: app-decisions
description: "Which tools/apps are in or out of the tidy-home guide, and the plan (VM rehearsal, then factory reset)"
metadata:
  node_type: memory
  type: project
  originSessionId: 220507be-49d4-4c8b-abc4-12bbe094097a
  modified: 2026-10-24T18:10:41.821Z
---

The project's own decisions log is `~/Developer/tidy-home/scratchpad/decisions.md`; keep it current. Start a new session by reading `scratchpad/handoff.md` (written 2026-10-25), then decisions.md.

Plan (2026-10-24): VM parked; testing continues on the user's own Mac (dev toolchains). Later the user factory-resets the Mac and follows the finished guide for real. Goal: minimal setup, few desktop apps, ideally no LaunchAgent (only needed for desktop apps that read a relocation variable and nothing else).

- VS Code: IN (needed for GitHub Copilot Pro). Portable mode via `/Applications/code-portable-data` link, created before first launch.
- Hermes: OUT, both CLI and app (2026-10-24).
- Codex CLI and dsh CLI: IN (ChatGPT Plus, DeepSeek credits).
- NO LaunchAgent at all (2026-10-24): user doesn't want the "zsh" item in Login Items → Allow in the Background. So desktop apps that only read a relocation variable (ChatGPT, DeepSeek Harness app) can't be in the core guide; replacements: chatgpt.com in a browser + Codex CLI, `dsh web`. (User went back and forth on these two apps; final word was "no LaunchAgent".)
- Pi: IN (user likes it). OpenCode (app + CLI): IN as the coding agent for Copilot + Vertex. Goose (app + CLI): IN as the general assistant (user wanted Hermes' general-use vibe; final 2026-10-24: keep both). gcloud CLI IN for the ADC login. User does NOT want GOOGLE_CLOUD_PROJECT/LOCATION lines in .zshenv or .zshrc: OpenCode 2.1.3 reads `provider.google-vertex.options.project`/`location` from opencode.json before env (verified 2026-10-24 with gemini-4-argon, no env vars, home unchanged); Pi 1.4's `/login` → Vertex → ADC stores project+location in auth.json (read from Pi's code, not yet tested).
- Codex is onboarded as reviewer/fact-checker; it writes only to `reviews/`, Claude is the single writer.

Related: [[explicit-order-and-reminders]]
