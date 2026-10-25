# clean-home audit

Reviewed: 2026-10-24 (Asia/Dhaka). Scope: all 32 files under `~/Developer/clean-home`: README, nine guides, 13 tool pages, three config files, six scripts. No archive files were changed. No installs, app launches, login flows, configuration changes, or repair scripts were run.

VERIFIED = independently supported by the cited source or static inspection; LIKELY = plausible archival observation without independent reproduction; OPINION = recommendation. A VERIFIED finding about flawed logic does not imply its failure was reproduced on this Mac. P1 = resolve before reuse; P2 = correct or qualify; P3 = editorial/policy.

## Overall judgment

Use the archive as a dated experiment log, not a tested fresh-Mac tutorial. Its strongest reusable facts are XDG defaults, basic relocation variables, the distinction between shell and GUI environments, and the recorded warning about login ordering. Its weakest claims are universal negatives inferred from strings, complete-cleanup guarantees, app-version behavior without retained evidence, and treating a successful checker as proof of the whole setup.

## Findings, ranked by severity

### 1. P1 — VERIFIED: automatic repair can move real state without proving ownership

Evidence: `scripts/repair-late-apps.sh` selects `junk_after_boot=(.codex .hermes .vscode .vscode-shared "Library/Application Support/Code")`, then checks only `stat -f %B "$p" >= boot` before `mv`. Cleanup runs even when no app was restarted. It can terminate a process, wait briefly, and move state without verifying all writers exited. Birth time does not establish that a folder is disposable, empty, or created by the offending launch. It also waits until the monitoring loop ends before reopening apps.

Suggested fix: do not port this script or automatic trashing. Keep the new checker read-only and report paths for human investigation. The archive's observation that a running app recreated a transcript is useful evidence for quitting all writers before any manual move.

### 2. P1 — VERIFIED: exported ZDOTDIR changes where subsequent shells look for .zshenv

Affected: README, `guides/shell-environment.md`, `config/zshenv`.

Evidence: [zsh startup files](https://zsh.sourceforge.io/Doc/Release/Files.html) says commands are read from `$ZDOTDIR/.zshenv`; HOME is used when ZDOTDIR is unset. RCS can suppress user startup files. The template exports ZDOTDIR. Consequently a nested zsh inheriting it looks under `~/.config/zsh`, and does not necessarily re-read the bootstrap `~/.zshenv`. `zsh -f` is another exception. Local read-only check `/bin/zsh -f -c 'print "inherited ZDOTDIR=${ZDOTDIR:+present}"'` printed `inherited ZDOTDIR=present`.

Suggested fix: replace “always/every shell” and “has to live in ~” with the actual lookup rules. Document an intentional bootstrap strategy, inherited values, and when a fully quit/reopened Terminal is required. A new tab inside an existing app with inherited ZDOTDIR may retain old values. Do not assume an agent command shell is equivalent to a fresh Terminal launch.

### 3. P1 — VERIFIED: migration examples can partly succeed, nest directories, or fail on absent inputs

Evidence from the archive:

- Claude move requires `~/.config` to exist and requires both `.claude.json` and `.claude.json.backup`; the latter is optional in real installations. Its destination guard `! -e` does not reject a dangling symlink. Multiple moves are not atomic.
- Pi uses `mv ~/.pi/agent ~/.config/pi/agent` without rejecting an existing destination, then appends the relocation variable only afterward.
- VS Code unconditionally moves optional `agent-plugins` and `argv.json`; `~/.vscode-shared/*` fails in default zsh when empty and omits hidden entries. An existing destination can cause nesting.
- The transcript-repair recipe blindly appends content. It does not establish that the recreated file contains only a missing suffix, so duplication is possible.

Suggested fix: rewrite these as guarded manual procedures with explicit source/destination expectations, backup, all writers quit, optional-file branches, verification, and recovery after partial failure. Configure relocation before reopening. Do not reuse the transcript concatenation as generic recovery advice.

### 4. P1 — VERIFIED: the old audit cannot certify tidy-home's expanded scope

Evidence: `scripts/home-audit.sh` iterates only `~/.*(DN)`. It cannot detect `~/go` or any other non-dot clutter. Its allowlist has no opt-in exceptions. `home-watch.sh` polls once per second, ignores baseline entries forever, and never reports a name again after first seeing it; it cannot guarantee detection of transient or recurring changes.

Suggested fix: define allowed ordinary home entries and opt-in exceptions explicitly. Report unexpected top-level entries without inspecting their contents. Describe polling limitations; remove “the moment anything new appears” and “all good” as whole-system guarantees.

### 5. P1 — VERIFIED: the health checker is not read-only and its checks can misclassify settings

Evidence: `health-check.sh` calls `mkdir -p`, appends `health.log`, and optionally invokes notification AppleScript. It checks Codex TOML with `grep -A1`, so valid whitespace/comments between the table and key cause false alarms. Commented JSON keys can satisfy grep checks. The Hermes awk searches any `enabled:` under `telemetry:` rather than the intended nested field. Goose is checked only in a YAML file despite the documented environment override.

Process checks accept any value merely because `VAR=` exists, and tokenize process output on spaces. Launchd comparisons derive their variable inventory from the installed plist, so a new variable omitted from that plist is invisible. No semantic test proves that an app used the requested location.

Suggested fix: rebuild the checker for this project's read-only contract, use format-aware checks where practical, compare required variable values against an independent inventory, and report “not checked/unknown” separately. Never output full process environments or auth/config contents.

### 6. P1 — LIKELY: the recorded login race is valuable; the proposed cure is not established

Evidence: `guides/staying-clean.md` explicitly reports a real restart failure and says the second restart with all defences was “Not yet tested.” Disabling restored windows removes one launch source, not every possible login/startup source. The repair window is 180 seconds from script start, gated by uptime under 600 seconds, rather than strictly the first three minutes after boot.

Independent boundary: local `man launchctl | col -b` documents `setenv` as applying to “all future processes launched by launchd in the caller's context.” It does not promise ordering before other login jobs or change already-running processes.

Suggested fix: retain the race as dated history. Keep a LaunchAgent out of the minimal path unless a selected app proves it needs one. Prefer supported app settings or location discovery independent of inherited variables, with full quit/reopen where needed. Do not promise that disabling restored windows eliminates the race.

### 7. P2 — VERIFIED: fresh-Mac shell/bootstrap prerequisites are missing

Evidence: `config/zshenv` only exports variables; it neither creates the destination directories nor installs relocated `.zprofile`/`.zshrc`. No archive instruction establishes Homebrew's shell setup in the relocated profile. Local `rg -n 'HISTFILE|SHELL_SESSION_DIR' /etc/zshrc /etc/zshrc_Apple_Terminal` showed `HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history` and session storage under `${ZDOTDIR:-$HOME}/.zsh_sessions`.

Suggested fix: the new tutorial needs explicit directory creation, bootstrap/profile placement, Homebrew PATH initialization, and a Terminal restart before first tool use. Explain that macOS's system zsh configuration currently locates history there; ZDOTDIR itself is not a universal history relocation setting. Preserve pre-existing shell customizations rather than telling readers to delete unexpected profiles blindly.

### 8. P2 — VERIFIED: Homebrew uninstall and zap serve different purposes

Evidence: `guides/installing-tools.md` calls `brew uninstall` a clean uninstall. [Homebrew's Cask Cookbook](https://docs.brew.sh/Cask-Cookbook#zap-stanza) describes zap as “a more complete uninstallation” and says its procedures are not performed by default. The same documentation acknowledges that generated zap lists may miss paths.

Suggested fix: trust the archive's separate statement that zap is a hint. Remove any implication that ordinary uninstall removes user data, that an empty zap list proves a clean app, or that installation through brew prevents tools from creating home files. Avoid deleting shared CLI/app data based on cask metadata alone.

### 9. P2 — VERIFIED: strings cannot establish the absence of a relocation mechanism

Evidence: `guides/auditing-a-new-tool.md` infers “unavoidable” for agy from strings; `tools/removed-tools.md` says the binary reads no relocation variable. Printable-string inspection cannot resolve computed paths, configuration files, dynamic libraries, runtime flags, or future versions. `tools/candidates.md` similarly infers that Kilo Desktop “would create” two folders from bundled Python code without establishing those code paths execute.

Suggested fix: preserve positive string/source matches as clues with exact artifact version and code context. Reword negatives as “no supported override found in this version.” Require runtime evidence for actual writes and distinguish bundled code from executed code. The removed-tools opening also overgeneralizes CodexBar: its subsection supplies no offending home path or relocation investigation.

### 10. P2 — VERIFIED: npm cache relocation does not cover npm's user configuration

Evidence: [npm configuration](https://docs.npmjs.com/cli/v11/using-npm/config/) documents the per-user file default as `$HOME/.npmrc` and supports `NPM_CONFIG_USERCONFIG`/`npm_config_userconfig`. The archive sets only `npm_config_cache`.

Suggested fix: trust the cache variable for cache relocation, not a blanket clean-home guarantee. Cover user configuration before workflows that write it. Qualify `/opt/homebrew/lib/node_modules` as dependent on npm's effective prefix. Restrict cache-deletion assurances to npm's documented cache content, not an arbitrary directory based solely on its name.

### 11. P2 — VERIFIED: Codex's core settings are supported, but credentials and auxiliary paths need qualification

Evidence: [advanced configuration](https://learn.chatgpt.com/docs/config-file/config-advanced) states “Codex stores its local state under `CODEX_HOME` (defaults to `~/.codex`).” It lists config, history, and conditional file-based auth. [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) documents `analytics.enabled` and credential storage modes `file`, `keyring`, `auto`, and `ephemeral`. Therefore `auth.json` is not unconditional. Analytics being disabled does not establish that every client data collection or trace export is disabled.

Suggested fix: retain `CODEX_HOME` and `[analytics] enabled = false`. Explain mixed settings/state under this tool-specific root even if placed inside `.config`. Treat auth paths as conditional; do not commit that directory to a dotfiles repo. Do not promise the variable relocates every related app/helper/skill path, or that creating the directory is a documented hard requirement without version-specific evidence.

### 12. P2 — LIKELY: ChatGPT update and shared-config behavior are version-specific observations

Evidence: archive `tools/codex-and-chatgpt.md` records Codex app 26.623 → ChatGPT 26.1021, a stray notify write being fixed, an analytics-default argument, and `mcp_servers.node_repl` being added. Local read-only Info.plist checks confirmed installed ChatGPT version `26.1021.31345`, bundle ID `com.openai.codex`. They do not reproduce the update, helper writes, process arguments, Dock environment, or app behavior with CODEX_HOME absent.

Suggested fix: retain this as dated history, not “fixed upstream” for every release. Validate the intended current app in the VM before publishing the optional GUI section. Confirm which config entries the app actually writes and whether the CLI loads them. The official reference supports dotted `-c` overrides, but the particular MCP name remains an observation.

### 13. P2 — VERIFIED: VS Code's sibling portable directory is documented; fresh install caveats are missing

Evidence: [VS Code portable mode](https://code.visualstudio.com/docs/setup/portable) documents `code-portable-data` beside the macOS app, and warns portable mode will not work while the app is quarantined. It says automatic updates should work on macOS. Thus the sibling directory is sound, but successful operation of the archive's symlink, all newer data categories, and Homebrew upgrades needs its own test.

Suggested fix: retain the documented directory mechanism. State installation location, destination creation, existing-link handling, permissions, and fresh-download/quarantine expectations. The link name belongs to the app's parent directory, not universally `/Applications`. Avoid a global VSCODE_PORTABLE value for multiple forks without explicitly considering profile sharing. Do not treat a missing `Code` directory as proof of every extension's cleanliness.

### 14. P2 — VERIFIED: scheduling and exit-status claims overstate what the plists prove

Evidence: local `man launchd.plist | col -b` says RunAtLoad runs when loaded, and StartInterval firings during sleep or an existing run are missed. The check plist delays only when uptime is below 600 seconds; login after a long uptime does not get the promised two-minute delay. `local.xdg-env.plist` ends with unconditional `exit 0`, masking individual `launchctl setenv` failures. Both plists contain user-specific absolute log paths. `background-items.md` says only one installed plist exists while documenting two agents elsewhere.

Suggested fix: do not carry automatic checks into the manual/read-only baseline. If documenting them later, describe load versus login, uptime versus login time, missed intervals, and accurate error handling. A zero job exit is not proof the environment was set. Regenerate user-specific paths manually and reconcile stale background-item descriptions.

### 15. P2 — LIKELY: background permission and deletion claims need macOS-specific evidence

Evidence: `guides/background-items.md` groups updaters, automation, servers, and login behavior under one permission and says everything works while open. `guides/removing-an-app-completely.md` says protected WebKit paths clear at restart and Finder can remove protected containers. No retained permission/error logs, macOS build, or per-app entitlement evidence establish these universal claims.

Suggested fix: present only observed behavior for a named macOS/app build. Do not guarantee Finder access, post-reboot cleanup, or which features a permission toggle disables. The depth-limited name search with errors suppressed cannot prove “every trace” is gone. Birth time cannot reliably distinguish ownership of shared files. Do not publish full Keychain dumps or process environments as general diagnostic output.

### 16. P2 — LIKELY: many per-tool assertions lack independently reusable evidence

Evidence: most tool pages say “verified” but retain no command transcript, complete version pair, source revision, or before/after inventory. `tools/candidates.md` cites a third-party Qwen environment reference. `tools/opencode.md` explicitly leaves Vertex option names unchecked. A source URL or copied expression without file/revision is insufficient for future verification.

Suggested fix: carry the following forward only with the bounded trust levels below. Login details, telemetry defaults, provider support, exact cask names/versions, and negative portability claims should be rechecked at the page-review stage. Remove the real project ID and unrelated provider/credit claims from the minimal home-folder tutorial; billing eligibility is account-specific.

## Facts to retain and limits on that trust

| Archive fact | Judgment and independent evidence | Suggested treatment |
|---|---|---|
| XDG config/data/state/cache defaults and absolute paths | VERIFIED: [XDG 0.8](https://specifications.freedesktop.org/basedir/latest/) defines all four defaults and requires absolute paths. | Retain. `.local/bin` is covered too. Backup choices are policy, not spec requirements. |
| Separate config, data, state, cache | VERIFIED as spec semantics; OPINION as backup strategy. | Retain rationale; credentials and important sessions may live wherever a tool puts them. A whole tool root under `.config` is not all “small settings.” |
| Apple silicon Homebrew prefix | VERIFIED: [Homebrew FAQ](https://docs.brew.sh/FAQ#why-should-i-install-homebrew-in-the-default-location) identifies `/opt/homebrew`. | Retain for the stated native/default-prefix scope; distinguish package files from runtime state. |
| launchctl affects future launches | VERIFIED: local `man launchctl`, quoted above. | Retain as an optional mechanism with ordering/inheritance limits. Apps may independently invoke shells or resolve settings. |
| Claude config relocation | VERIFIED for CLI settings/history/plugins: [Claude settings](https://code.claude.com/docs/en/settings) documents `CLAUDE_CONFIG_DIR`. | Retain basic variable. `.claude.json` relocation, path-keyed Keychain behavior, Desktop UI and output-style issue remain LIKELY archival observations. |
| Copilot CLI relocation | VERIFIED: [GitHub CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) defines COPILOT_HOME for config/state. It describes credential-store fallback to a plaintext file. | Retain variable; qualify Keychain claims. Current docs use `settings.json`, so archive references to `config.json` are version-sensitive. VS Code extension behavior remains unverified. |
| gcloud config default | VERIFIED: [Google configurations](https://docs.cloud.google.com/sdk/docs/configurations) gives macOS `~/.config/gcloud` and CLOUDSDK_CONFIG. | Retain for gcloud; do not extrapolate to gsutil or every Google SDK. |
| OpenCode global config | VERIFIED: [OpenCode config](https://opencode.ai/docs/config/) documents `~/.config/opencode/opencode.json`. | Retain that path. Exact credential database, state/cache behavior and Desktop cleanliness remain LIKELY, not independently verified here. |
| Hermes HERMES_HOME and installer side effects | LIKELY: detailed archive observation, no independent source/runtime confirmation here. | VM priority because first launch installs another engine and reportedly writes home profiles. |
| DSH_HOME, DSH_AGENTS_HOME, telemetry mode and shared login | LIKELY: archive names implementation/profiles but lacks source revision/transcript. | Recheck package provenance, desktop/CLI versions, first-run paths and telemetry before use. |
| Pi variable, MCP/version and PI_TELEMETRY | LIKELY: archive attributes variable to help, but retains no output. | Recheck exact upstream package and version; do not publish “Pi 1.4” features as timeless facts. |
| Goose XDG, telemetry, Keychain and provider claims | LIKELY: no independent confirmation in this pass; attempted old environment-doc route returned 404. | Resolve current primary docs/source before inclusion; no successful fetch is not evidence of absent support. |
| Kilo, Cline, Qwen, Crush, OpenHands, removed apps | LIKELY: snapshot observations, mixed primary/secondary sourcing and negative inference. | Keep as research leads, not a maintained compatibility list. Pin versions and retain evidence if brought into scope. |
| Keeping standard XDG defaults reduces divergence | OPINION supported by the archive's reported experiment. | Retain as rationale, not a claim that every tool ignores overrides or every future app recreates `.cache`. |
| No root symlinks; exceptions for necessary tools | OPINION/project policy. | Align with tidy-home's opt-in exceptions instead of mandatory tool removal. |

## What I would test first in the fresh VM

These are review priorities and acceptance criteria, not a dry-run command sequence.

1. **Shell bootstrap, before tools:** fresh Terminal, nested zsh, noninteractive zsh, and a reopened Terminal after edits. Establish which startup files run, inherited ZDOTDIR behavior, Homebrew PATH, history/session paths, and that the relocated directories exist. This is the dependency for every CLI claim.
2. **Minimal scope and checker:** ordinary macOS home entries, opted-in SSH, and visible clutter such as `~/go`. [Go's module reference](https://go.dev/ref/mod#go-install) documents default executable placement under `$HOME/go/bin` when GOPATH is unset. The archive has no Go relocation coverage. Establish that the new checker reports without logging, creating folders, notifying, or printing secrets.
3. **Only the GUI apps actually selected:** default Dock launch and full quit/reopen using documented app settings or portable discovery, with no LaunchAgent. For ChatGPT, observe current CODEX_HOME handling, config/helper writes and analytics setting persistence. Decide from those results whether an optional LaunchAgent section is needed.
4. **VS Code fresh installation:** actual cask build, portable sibling/link discovery, quarantine/translocation implications, first launch, extension installation, and upgrade. Confirm no home `.vscode*` entries reappear; do not assume extensions honor the core app's layout.
5. **CLI first-run versus installer effects:** installation, help/version, authentication, normal use, and update can have different writes. Prioritize npm configuration, Claude/Copilot credentials, and any selected Hermes/DSH/Pi/Goose features. Record exact package/app versions and separate CLI from bundled Desktop engines.
6. **Manual migration recovery, if migration is included:** optional inputs absent, destination already present, dangling link, partial failure, and writers not fully quit. The expected result includes intact sessions/settings and no directory nesting. Do not use automatic transcript concatenation or timestamp-based cleanup.
7. **Optional GUI environment mechanism, only if needed:** actual login after long uptime, full restart, restore-windows enabled/disabled, and subsequent app launch. Acceptance requires reliable location selection; a plist exit code or environment-variable presence alone is insufficient.

## Verification record and remaining limits

- Read every archive file; no .git metadata was needed. Inventory used `rg --files -uu ... -g '!**/.git/**'` and `find ... -type f` (32 files).
- Syntax-only `/bin/zsh -fn` on all six scripts: `all six scripts parse`. No script bodies were executed.
- `plutil -lint` on both archived plists: each `OK`. XML validity does not establish launchd/runtime correctness.
- Read local launchctl/launchd.plist manuals and system zsh configuration; inspected only app version and bundle-ID metadata. No credentials, Keychain contents, user config contents, or full process environments were printed.
- Fetched primary documentation linked above. Google ADC documentation was also opened, but this audit does not certify the archive's provider-specific integration or credit eligibility. VS Code telemetry documentation fetch timed out; the exact crash-reporter rewrite behavior remains unverified. An attempted installed VS Code bootstrap-source path did not exist; no source-level portable-path claim was inferred from that failure.
- Did not run brew metadata commands: they can populate caches/update metadata. Exact current formula/cask availability, zap lists, installed binary behavior, telemetry network traffic, auth state, GUI environment inheritance and original historical events were not independently reproduced.
- No claim that all archive facts have been verified. Facts without supporting independent evidence are explicitly held back above; “nothing new in ~” in one session cannot establish permanent cleanliness across updates and features.
