# Forge Fish Plugin

A fish-native integration for [Forge](https://github.com/TopherMayor/forge) that mirrors the zsh plugin’s core workflows as closely as fish allows.

## At a glance

| Category | Status |
| --- | --- |
| Auto-load integration | Yes |
| Forge-aware right prompt | Yes |
| Prompt command dispatch | Yes |
| Conversation helpers | Yes |
| Model/provider pickers | Yes |
| Workspace helpers | Yes |
| Commit/suggestion helpers | Yes |
| Fish key bindings | Yes |
| Fish completions | Yes |
| Native zsh parity | Partial |

## What it provides

- An auto-loaded fish integration via `~/.config/fish/conf.d/forge.fish`
- A Forge-aware right prompt showing:
  - active agent
  - model
  - reasoning effort
  - short conversation id
- Interactive command dispatch from the prompt using `:` commands, with Forge responses starting on a fresh line
- Conversation helpers:
  - new
  - switch
  - clone
  - rename
  - copy
  - dump
  - compact
  - retry
- Model and provider pickers
- Configuration helpers for model, commit model, suggest model, and reasoning effort
- Workspace helpers
- Commit and suggestion helpers
- Fish key bindings for Forge actions
- Fish completion support for `forge`

## How it loads

Fish automatically loads files in `~/.config/fish/conf.d/`, so the plugin activates at shell startup without manual sourcing.

The completion file at `~/.config/fish/completions/forge.fish` is also loaded automatically by fish.

## Feature parity with the native zsh plugin

The fish plugin is **functionally close** to the native zsh plugin, but it is **not 1:1**.

### Usage comparison

| Area | Fish plugin | Native zsh plugin | Status |
| --- | --- | --- | --- |
| Startup/loading | Auto-loads through `~/.config/fish/conf.d/forge.fish` | Loaded through `eval "$(forge zsh plugin)"` and `eval "$(forge zsh theme)"` in `.zshrc` | Different shell-native plumbing |
| Prompt/status | Fish right prompt shows Forge status, active agent, model, effort, and conversation id | zsh theme sets `RPROMPT` with Forge status | Similar intent, different implementation; fish now also starts responses on a fresh line |
| Command dispatch | Uses `:` commands in the fish command line, and inserts a leading newline before Forge output | Uses zsh editor hooks and line-editing behavior | High functional overlap |
| Selectors | Provides fish pickers for conversations, models, providers, and agents | Uses native zsh selection helpers | Similar workflow |
| Key bindings | Binds Enter, Tab, and Ctrl-V for Forge actions | Uses `zle`-based bindings | Same intent, different editor model |
| Fish completions | Fish completions for top-level commands, help targets, zsh helpers, and key flags | Rich generated completion tree in zsh | Fish is lighter |

### Current missing parity

| Missing or partial parity | What is different | Impact |
| --- | --- | --- |
| Completion depth | Fish completions now cover more root commands, zsh helpers, and key flags, but still do not match the zsh plugin’s generated tree | Fewer nested subcommand suggestions |
| Exact theme fidelity | Fish has its own right prompt formatting instead of the zsh `RPROMPT` theme path | Visual output differs |
| Editor integration | Fish uses `commandline`/bind handlers instead of zsh `zle` workflows | Same goal, different mechanics |
| Native zsh-only behavior | Some zsh plugin internals are shell-specific and not directly portable | Not a literal 1:1 port |

## Usage

Start a new fish shell, then use Forge normally:

```fish
forge
forge info
forge zsh plugin
```

Prompt commands can be entered directly into the fish command line, for example:

```fish
:help
:new
:conversation
:model
:provider-login
:commit
```

## Files

- `~/.config/fish/conf.d/forge.fish`
- `~/.config/fish/completions/forge.fish`

## Notes

This repo contains the fish integration files only. It is intended to be a practical fish-native equivalent of the Forge zsh plugin rather than a literal port.

Recent updates also ensure Forge responses appear on their own line, which keeps the command flow closer to the zsh plugin’s editor-driven output separation.

