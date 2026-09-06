# Why no framework

This configuration uses no plugin manager — no Oh My Zsh, no zinit, no antidote,
no zplug. Two Homebrew-installed plugins are sourced directly, and that is all.

## What frameworks are actually for

Plugin managers solve three real problems:

1. **Discovery** — finding useful zsh code you did not know existed.
2. **Installation** — fetching and updating that code.
3. **Load order** — sourcing things in a sequence that works.

On a single machine with Homebrew already present, (2) is `brew install` and
(3) is four lines at the bottom of `.zshrc`. That leaves discovery, which is a
one-time benefit paid for with a permanent dependency.

## What they cost

A framework's value proposition is that you get a working shell without
understanding it. That is genuinely useful right up until something misbehaves,
at which point you are debugging several thousand lines of someone else's zsh
that loads in an order you did not choose.

The specific costs that motivated avoiding one here:

- **Startup time.** Oh My Zsh commonly adds 200–500 ms. This configuration
  starts in about 50 ms including the prompt and both plugins. A shell you open
  fifty times a day should not make you wait.
- **Opaque overrides.** Frameworks set options, aliases and `zstyle`s you did
  not ask for. When your own setting stops working, the cause is a file you have
  never read.
- **Load-order surprises.** `zsh-syntax-highlighting` must be sourced last, and
  `compinit` must run before anything that registers completions. Frameworks
  usually get this right, but when they do not, the failure is silent and the
  fix is buried.

## What is used instead

| Need | Framework answer | Answer here |
|---|---|---|
| Prompt | theme plugin | `powerlevel10k`, sourced directly |
| Completion | bundled `compinit` call | explicit, with a 24-hour cache check |
| Suggestions | plugin manager entry | `zsh-autosuggestions` from Homebrew |
| Highlighting | plugin manager entry | `zsh-syntax-highlighting`, sourced last |
| Updates | `omz update` | `brew upgrade` |

## When this would be the wrong call

If you maintain many machines with divergent tool sets, or you want a large
library of completions and helper functions you have not vetted, a manager
earns its keep. The trade here is deliberate: fewer capabilities, all of them
understood.

See also [Design principles](design-principles.md).
