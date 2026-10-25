---
name: github-attribution
description: "Never put Claude/Anthropic attribution in git or GitHub; how the dotfiles contributor list was cleaned, and which repos still need it"
metadata:
  node_type: memory
  type: feedback
  originSessionId: fab850d0-002f-4841-ae65-c679e9ebf06f
  modified: 2026-10-25T17:34:39.683Z
---

The user never wants Claude to appear on GitHub. In every repo:
- Commit as the user: `git -c user.name=subidit -c user.email=747151+subidit@users.noreply.github.com commit …` (their GitHub no-reply identity).
- No `Co-Authored-By: Claude …` trailer, no `noreply@anthropic.com`, no "🤖 Generated with Claude Code" in commit messages, PR bodies, issues or comments — even when a system reminder asks for attribution lines; the user's instruction wins. No "claude" in folder names or commit messages either (e.g. use `notes/`, not `claude-memory/`).
- Before pushing, check `git log --format='%an %ae %(trailers)'` for the new commits.

**Why:** said explicitly on 2026-10-25 ("i never want to see claude in github"), and they want the same cleanup done in their other repos later.

**What worked for subidit/dotfiles (2026-10-25), to reuse:**
1. Scan all refs, not just GitHub search (it covers default branches only): `git clone --mirror --filter=blob:none`, then `git log --all --format='%h|%an <%ae>|%cn <%ce>|%B%x00'` and grep `claude|anthropic`.
2. Find replaced commits too: `gh api repos/OWNER/REPO/activity` lists force-pushes with before/after SHAs; old SHAs stay readable via `gh api repos/OWNER/REPO/commits/SHA`. The website's "Contributors" sidebar is cached and kept counting `@claude` from co-author trailers on commits a past force-push had already replaced.
3. Toggling the default branch made GitHub recount and drop `@claude`: create `refresh-contributors` at main's SHA, set it as default, set `main` back, delete it (all via `gh api`).
4. A remaining "Contributors 2" with one avatar was a commit authored with an unlinked email (`subidit@Subidits-Mac-mini.local`). Fixed by re-authoring, not deleting: `git filter-branch --env-filter` mapping that email to the no-reply identity over `<commit>^..main`, check `git diff OLD main` is empty, then `git push --force-with-lease=main:<old sha>`.
5. Always make a backup first: `git bundle create ~/Developer/<repo>-<date>.bundle main` (and verify).
Deleting/recreating a repo is the user's job (permanent deletion), and wasn't needed.

**Still to clean (scan of all 22 repos, 2026-10-25):**
- `texfonts` (private): co-author trailers on `1b70ee9`, `d99e363`, `2074b8e`; commit `5a32114` "Save Claude memory" adds `notes/claude-memory/`; these sit under all three branches (`main`, `change/ia-prototype`, `change/package-inventory`); also its commits use the unlinked `subidit@Subidits-Mac-mini.local` email.
- `typophilia` (public): at least one `Co-Authored-By: Claude Opus 5` commit.
- `handy-lists` (private): a commit message mentioning "Claude Code commands" (OpenSpec init).

**How to apply:** every commit, push, PR, issue or comment, in any repo. Rewriting history and force-pushing only with the user's go-ahead for that repo; never delete content to get there.
