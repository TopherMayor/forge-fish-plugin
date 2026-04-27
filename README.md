# Forge Fish Plugin

A fish-native integration for [Forge](https://github.com/TopherMayor/forge) that mirrors the zsh plugin’s core workflows as closely as fish allows.

## What it provides

- An auto-loaded fish integration via `~/.config/fish/conf.d/forge.fish`
- A Forge-aware right prompt showing:
  - active agent
  - model
  - reasoning effort
  - short conversation id
- Interactive command dispatch from the prompt using `:` commands
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

### High parity

- Interactive action surface
- Conversation/model/provider selectors
- Forge-aware prompt/status display
- Prompt-driven command dispatch
- Keybinding-driven workflow

### Medium parity

- Prompt styling and theme behavior
- Selector behavior and buffer editing flow

### Lower parity

- Completion depth
- Exact zsh editor integration
- Native zsh theme internals

## Key differences from zsh

- zsh uses `eval "$(forge zsh plugin)"` and `eval "$(forge zsh theme)"`
- fish uses native auto-load integration through `conf.d` and `completions`
- fish uses `commandline`/bindings instead of zsh’s `zle`-based editor model
- fish completions are useful, but not as exhaustive as the zsh plugin’s generated completion tree

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
