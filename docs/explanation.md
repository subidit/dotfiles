# Explanation

Understanding-oriented. The reasoning behind the shape of this config, not what to type.

## Why no framework

Oh My Zsh and similar exist to solve discovery, installation, and load order. On a single machine with Homebrew, installation is `brew install` and load order is a handful of ordered lines — that leaves only discovery, a one-time benefit paid for with a permanent dependency and slower startup. Two plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) are used directly; everything else is bare zsh, understood line by line.

## Why `ZDOTDIR` instead of full XDG

`XDG_CONFIG_HOME`/`XDG_CACHE_HOME`/etc. exist to make Linux desktop apps behave consistently across different desktop environments (GNOME vs. KDE). That problem doesn't exist on macOS. The only part of XDG actually wanted here — keeping `$HOME` free of dotfiles — is fully solved by `ZDOTDIR` alone. `XDG_CACHE_HOME` got added later, but only because Powerlevel10k's own cache files specifically check for it; it's not a general policy.

One file can never move: zsh always reads `~/.zshenv` before it knows where `$ZDOTDIR` even is. That's the one unavoidable bootstrap.

## Why test before adding

Every option in this config was flipped on live (`setopt X`, observe, `unsetopt X` if wrong) before it went into `.zshrc`. This caught real things that guessing would have missed: `menu select` silently doing nothing without `zmodload zsh/complist`, an arrow-key binding aimed at the wrong escape sequence (twice), `$fpath` genuinely triplicated by Homebrew's own zsh build. Assuming a config line does what its name suggests is how those stay hidden.

## Why some things were deliberately skipped

Not everything from a reference config is worth copying. `AUTO_PUSHD` and the directory stack were skipped because `zoxide` solves "get back to a directory" better — persistent across sessions, frecency-ranked, versus a stack that resets every time the terminal closes. `special-dirs` (`.`/`..` in TAB menus) was skipped because typing `..` is faster than tabbing to it. The lesson generalizes: a setting existing, and even working correctly, isn't a reason to want it.

## Why per-terminal differences appeared, then mostly disappeared

Early on, Ghostty had a bundled Nerd Font and the other two terminals didn't, so `eza --icons` and the prompt config briefly branched on `$TERM_PROGRAM`. Once real Nerd Fonts were installed and set as the actual terminal fonts everywhere, the underlying inequality that justified branching was gone, and the branches were removed. The technique (documented in `how-to.md`) stays useful — the specific instances of it don't, once the reason for them stops being true.

## Why a separate `colors.zsh`

`.zshrc` handles shell *behavior* — options, bindings, completion, tool integration. Color is a distinct, optional concern layered on top, conditionally sourced so `.zshrc` works identically with or without it. Same reasoning as `.p10k.zsh`: a config file `.zshrc` depends on existing, not depends on the *contents* of.
