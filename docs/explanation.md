# Explanation

Understanding-oriented. The reasoning behind the shape of this config, not what to type.

## Why no framework

Oh My Zsh and similar exist to solve discovery, installation, and load order. On a single machine with Homebrew, installation is `brew install` and load order is a handful of ordered lines — that leaves only discovery, a one-time benefit paid for with a permanent dependency and slower startup. Two plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) are used directly; everything else is bare zsh, understood line by line.

## Why no prompt theme

Powerlevel10k was here for a while and did nothing wrong. The reason it left is that its value is proportional to how much of it you want but couldn't write yourself, and the answer turned out to be: a git segment and a clock. What it costs is a second configuration language (`.p10k.zsh` is generated and runs to four figures of lines), a background daemon (`gitstatusd`), an instant-prompt mechanism with opinions about what may print during startup, and a cache directory to relocate. The replacement is 87 lines doing the same job for this config, in the same language as the rest of it.

The general shape of the argument: a dependency earns its place by doing something hard. Drawing text with color escapes twice a second is not hard. Querying git status without blocking on a huge repository *is* hard — which is why, if a git segment ever goes back in, gitstatusd is the honest answer rather than a hand-rolled `git status` on every keystroke.

## Why the prompt is a separate, standalone file

Two different reasons, worth keeping apart.

**Separate file:** the prompt is the part of a shell config you fiddle with most, and the part with the least in common with everything else. `.zshrc` sets up behavior that then sits still for months; the prompt is where you go to change a color at midnight. Its own file means that editing never risks the working parts.

**Standalone:** it reads no `ZC[]`, no `PAL`, nothing from `colors.zsh` — it defines its own colors, with a truecolor branch and a 256-color fallback, and runs correctly under `zsh -f`. That makes it portable to a machine that has none of this config, and it means the palette file can be deleted, rewritten or broken without the prompt disappearing with it. The cost is a handful of hex values duplicated across two files. That's real, and accepted deliberately: the two files answer to different requirements, and coupling them to save five lines would hand the prompt all of the palette's failure modes.

## Why a separate `colors.zsh`

`.zshrc` handles shell *behavior* — options, bindings, completion, tool integration. Color is a distinct, optional concern layered on top, conditionally sourced so `.zshrc` works identically with or without it.

Its actual job is narrow and worth stating plainly: five tools (eza, the completion menu, fzf, zsh-syntax-highlighting, autosuggestions) each ship a different default color scheme, none of which knows what the terminal's background is. Run them side by side and the window looks like five applications. The palette is one set of hues, solved in OKLCH against the real `#282c34` ground for target contrast, handed to all five. That's the whole value, and no individual tool's config can provide it.

The file is the largest in the setup, and roughly 40% of it exists to color `eza -l` columns. That's a fair criticism. The counter-argument is that those hexes can't be re-derived by hand later, so the cost is paid once and the file is close to append-only afterwards.

## Why color by category, not by decoration

The palette has two rules: **lightness carries hierarchy, hue carries category.** Everything downstream follows from them.

It's what makes the prompt's path readable at a glance — ancestors in `dir` blue, the folder you're actually in one step brighter — instead of one flat color you have to parse. It's why the exit-status marks own green and red exclusively, so those two hues never mean anything else anywhere in the window. And it's the reason the eza extension map exists at all: eza's default scheme groups by *is this executable*, which paints a `.pem` private key the same green it uses for "fine". Grouping by what a file actually is means a stray secret is red, generated files recede, and config files share a hue with each other rather than with the shell scripts beside them.

The rule also catches its own violations. Prose was `dir` blue for about ten minutes, which made `notes.md` and `src/` the same hue with only bold distinguishing them — exactly the category collision the rule exists to forbid.

## Why `ZDOTDIR` instead of full XDG

`XDG_CONFIG_HOME`/`XDG_CACHE_HOME`/etc. exist to make Linux desktop apps behave consistently across different desktop environments (GNOME vs. KDE). That problem doesn't exist on macOS. The only part of XDG actually wanted here — keeping `$HOME` free of dotfiles — is fully solved by `ZDOTDIR` alone. `XDG_CACHE_HOME` got added later for one tool's cache files and stayed because `less` and others read it too; it's not a general policy.

One file can never move: zsh always reads `~/.zshenv` before it knows where `$ZDOTDIR` even is. That's the one unavoidable bootstrap.

## Why test before adding

Every option in this config was flipped on live (`setopt X`, observe, `unsetopt X` if wrong) before it went into `.zshrc`. This caught real things that guessing would have missed: `menu select` silently doing nothing without `zmodload zsh/complist`, an arrow-key binding aimed at the wrong escape sequence (twice), `$fpath` genuinely triplicated by Homebrew's own zsh build. Assuming a config line does what its name suggests is how those stay hidden.

The prompt rewrite added two more. `$''` raises `character not in range` the moment the locale isn't UTF-8 — fine in Ghostty, fatal over bare ssh — so the glyphs are stored as literal characters instead. And `${${(%):-%D{%l:%M %p}}## }`, which works in an assignment, silently breaks when re-expanded under `PROMPT_SUBST`, because the `}` inside `%D{...}` closes the outer substitution early. Both looked correct in the file and failed only when run.

## Why measure instead of assuming cost

"This will be slow" is a guess. `/usr/bin/time -p zsh -i -c exit`, five times, is an answer.

Measuring changed three decisions here. `vcs_info` for a git segment looked like the idiomatic choice and cost 69 ms per prompt — it shells out to git several times — against 9.5 ms for a single `git status --porcelain=v2 --branch` parsed in zsh. Command substitution inside `precmd` was invisible in the source and worth several ms per prompt in forks, because every `$(...)` is a subshell. And the entire duration/exit-status apparatus, which *looked* like the expensive part, measured at exactly zero against a bare prompt — it never forks at all.

Startup is ~40 ms, of which `compinit` is about half. Everything else — fzf, zoxide, both plugins, the palette — is under 10 ms combined.

## Why some things were deliberately skipped

Not everything from a reference config is worth copying. `AUTO_PUSHD` and the directory stack were skipped because `zoxide` solves "get back to a directory" better — persistent across sessions, frecency-ranked, versus a stack that resets every time the terminal closes. `special-dirs` (`.`/`..` in TAB menus) was skipped because typing `..` is faster than tabbing to it. A git segment in the prompt is skipped for now because the cheap version is wrong on big repositories and the correct version is a daemon. The lesson generalizes: a setting existing, and even working correctly, isn't a reason to want it.

## Why per-terminal differences appeared, then mostly disappeared

Early on, Ghostty had a bundled Nerd Font and the other two terminals didn't, so `eza --icons` and the prompt config briefly branched on `$TERM_PROGRAM`. Once real Nerd Fonts were installed and set as the actual terminal fonts everywhere, the inequality that justified branching was gone, and the branches were removed.

They came back, narrowly, for Apple Terminal: it ships no patched font, so it gets no eza icons and a glyph-free prompt. That's the test for whether a branch is justified — an actual capability difference between terminals, not a preference — and it's why each branch keys on the capability's consequence (icons on or off) rather than treating the terminal's name as meaningful in itself.
