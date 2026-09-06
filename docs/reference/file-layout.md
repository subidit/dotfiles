# File layout

## In this repository

```
.
├── README.md
├── Brewfile              # everything the configuration expects
├── install.sh            # symlinks repo → $HOME, idempotent
├── home/
│   └── .zshenv           # → ~/.zshenv
├── config/               # → $XDG_CONFIG_HOME
│   ├── zsh/
│   │   ├── .zshrc
│   │   ├── .zprofile
│   │   └── .p10k.zsh
│   ├── ghostty/config
│   └── ripgrep/config
├── tools/
│   └── palette-report.py # measures the palette; --check gates it
└── docs/
    ├── tutorials/
    ├── how-to/
    ├── reference/
    └── explanation/
```

`home/` maps to `$HOME`; `config/` maps to `$XDG_CONFIG_HOME`. The full map is
the `MAP` array in [`install.sh`](../../install.sh) — add a line there when you
add a file.

## On the machine after install

```
~/.zshenv                      → repo home/.zshenv
~/.config/zsh/.zshrc           → repo config/zsh/.zshrc
~/.config/zsh/.zprofile        → repo config/zsh/.zprofile
~/.config/zsh/.p10k.zsh        → repo config/zsh/.p10k.zsh
~/.config/ghostty/config       → repo config/ghostty/config
~/.config/ripgrep/config       → repo config/ripgrep/config
```

Written to, not versioned:

```
~/.local/state/zsh/history     shell history
~/.local/state/less/history    less search history
~/.local/state/{node,python,sqlite}/   REPL histories
~/.cache/zsh/zcompdump         completion cache
~/.cache/zsh/compcache         completion data cache
~/.cache/p10k-instant-prompt-*.zsh
```

## Load order

| File | Read by | When |
|---|---|---|
| `~/.zshenv` | every zsh | always, first |
| `$ZDOTDIR/.zprofile` | login shells | after `.zshenv` |
| `$ZDOTDIR/.zshrc` | interactive shells | after `.zprofile` |

Order inside `.zshrc` matters in three places:

1. The p10k instant-prompt block is first — anything printing before it breaks it.
2. `compinit` runs before anything that registers completions.
3. `zsh-syntax-highlighting` is sourced **last**; it wraps widgets defined
   before it and will miss any defined after.
