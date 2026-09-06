# Completion

## Initialisation

`compinit` is expensive: it scans every directory in `$fpath` and security-checks
each completion function. Doing that on every shell start costs 100–200 ms.

The cache is rebuilt only when it is more than 24 hours old:

```zsh
if [[ -n $_comp_dump(#qN.mh+24) ]]; then
  compinit -d "$_comp_dump"      # stale: full rebuild
else
  compinit -C -d "$_comp_dump"   # fresh: trust the cache
fi
```

`(#qN.mh+24)` is a glob qualifier — `N` for null-glob, `.` for regular files,
`mh+24` for modified more than 24 hours ago. It requires `EXTENDED_GLOB`.

Cache file: `$XDG_CACHE_HOME/zsh/zcompdump`.

If you install a tool and its completions do not appear, the cache is not yet
stale. See [how-to/troubleshoot.md](../how-to/troubleshoot.md#new-completions-are-not-showing-up).

## Matching

```zsh
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
```

Three rules, tried in order:

| Rule | Effect |
|---|---|
| `m:{a-zA-Z}={A-Za-z}` | Case-insensitive |
| `r:\|=*` | Substring — `log` matches `access_log` |
| `l:\|=* r:\|=*` | Partial in both directions |

## Behaviour

| `zstyle` | Effect |
|---|---|
| `menu select` | Arrow-navigable menu |
| `special-dirs true` | Offers `.` and `..` |
| `squeeze-slashes true` | `a//b` completes as `a/b` |
| `group-name ''` | Groups matches by type under headings |
| `use-cache on` | Caches expensive completions (package lists, and so on) |
| `cache-path` | `$XDG_CACHE_HOME/zsh/compcache` |

## Colour

```zsh
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
```

`LS_COLORS` is generated from the palette table, so a directory is the same blue
in `ls` output and in the Tab menu.

This is worth stating because the reverse is a common silent failure: if
`LS_COLORS` is unset — which it is by default on macOS, since BSD `ls` uses
`LSCOLORS` instead — this line expands to nothing and the menu is colourless
with no error.

Group headings and messages are coloured from the same table via `ZC`, the
zle-spelled mirror of the palette.

| Context | Colour role |
|---|---|
| `descriptions`, `messages` | `muted` |
| `warnings` | `alert` |
| `corrections` | `g_mod` |

## Menu keys

See [keybindings.md](keybindings.md#completion-menu).
