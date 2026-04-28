# Forge Fish Plugin

Forge's fish integration for prompt dispatch, command helpers, pickers, completions, and session persistence. This project is intended to sit alongside the upstream Forge plugin.

## Quick start

### Prerequisites

Before running the setup script, make sure:

- `fish` is installed and available in your `PATH`
- you have cloned this repository locally
- you can write to the target Fish config root (default: `~/.config/fish/`)
- `forge` itself is installed if you want to use the plugin immediately after setup

### Setup

From the plugin repo, run:

```fish
./setup.fish
```

This installs the fish integration into:

- `~/.config/fish/conf.d/forge.fish`
- `~/.config/fish/completions/forge.fish`

Setup options:

- `--copy` copies the files instead of symlinking them
- `--force` replaces existing destination files without keeping backups
- `--dry-run` previews the actions without changing anything
- `--target-dir PATH` installs into an alternate Fish config root

Example:

```fish
./setup.fish --dry-run --target-dir /tmp/fish-config
```

### Usage

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
:agent
:forge
:conversation
:model
:provider-login
:logout
:commit
```

Provider login/logout commands accept either a provider name or provider ID, but interactive selection always resolves to the provider's canonical ID before login/logout runs.

Provider-related completions also expose provider IDs so the command line stays aligned with the Forge backend's identifier model.

### How it loads

Fish automatically loads files in `~/.config/fish/conf.d/`, so the plugin activates at shell startup without manual sourcing.

The completion file at `~/.config/fish/completions/forge.fish` is also loaded automatically by fish.

## At a glance

| Category | Status |
| --- | --- |
| Auto-load integration | Yes |
| Forge-aware right prompt | Yes |
| Prompt command dispatch | Yes |
| Conversation helpers | Yes |
| Agent switching | Yes |
| Model/provider pickers | Yes |
| Workspace helpers | Yes |
| Commit/suggestion helpers | Yes |
| Fish key bindings | Yes |
| Session restoration | Yes |
| Native zsh parity | Partial |

## What it provides

- An auto-loaded fish integration via `~/.config/fish/conf.d/forge.fish`
- A Forge-aware right prompt showing:
  - active agent
  - model
  - reasoning effort
  - short conversation id
- Prompt command dispatch from the fish command line
- `:new` starts a fresh conversation and resets the active agent to `forge`
- `:agent` opens an interactive agent picker
- Bare agent commands like `:forge`, `:muse`, and `:sage` switch agents directly
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
- Session state persists across fish shells via universal variables, including conversation, model, provider, reasoning effort, and active agent
- Provider login/logout picker selections resolve to Forge provider IDs, so the fish plugin uses the same identifier whether you choose a provider by name or ID

## Feature parity with the native zsh plugin

The fish plugin is functionally close to the native zsh plugin, while remaining a separate fish-native integration.

### Usage comparison

| Area | Fish plugin | Native zsh plugin | Status |
| --- | --- | --- | --- |
| Startup/loading | Auto-loads through `~/.config/fish/conf.d/forge.fish` and restores universal session state | Loaded through `eval "$(forge zsh plugin)"` and `eval "$(forge zsh theme)"` in `.zshrc` | Different shell-native plumbing |
| Prompt/status | Fish right prompt shows Forge status, active agent, model, effort, and conversation id | zsh theme sets `RPROMPT` with Forge status | Similar intent, different implementation; fish also starts responses on a fresh line |
| Command dispatch | Uses `:` commands in the fish command line, and inserts a leading newline before Forge output | Uses zsh editor hooks and line-editing behavior | High functional overlap |
| Selectors | Provides fish pickers for conversations, models, providers, and agents | Uses native zsh selection helpers | Similar workflow |
| Key bindings | Binds Enter, Tab, and Ctrl-V for Forge actions | Uses `zle`-based bindings | Same intent, different editor model |
| Providers | Provider picker returns provider IDs, so `:provider-login` and `:logout` use the correct Forge identifier | Provider selection is id-based in zsh too | Same target, fish now avoids name/id mismatches |
| Fish completions | Fish completions for top-level commands, help targets, provider commands, zsh helpers, and key flags | Rich generated completion tree in zsh | Fish is lighter |
| Session restoration | Fish restores conversation, model, provider, reasoning effort, and active agent from universal variables | zsh keeps session state within the current shell/plugin context | Fish is persistent across shells |

### Current missing parity

| Missing or partial parity | What is different | Impact |
| --- | --- | --- |
| Completion depth | Fish completions cover the common root commands, help targets, provider commands, zsh helpers, and key flags, but still do not match the zsh plugin’s generated tree | Fewer nested subcommand suggestions |
| Editor integration | Fish uses `commandline`/bind handlers instead of zsh `zle` workflows | Same goal, different mechanics |
| Native zsh-only behavior | Some zsh plugin internals are shell-specific and not directly portable | Not a literal 1:1 port |

### Completion details

The biggest completion gaps are:

- deeper nested subcommand trees
- richer argument completion for prompt commands
- value completion for model, provider, conversation, and agent arguments
- more exhaustive `forge zsh` helper coverage

### Editor details

The biggest editor gaps are:

- zsh `zle` widgets are more native than fish `commandline` handlers
- fish can submit and rewrite lines, but it does not share zsh’s editor model
- picker cancellations and cursor restoration can still feel less integrated than zsh

## Upstream references

This project sits alongside the upstream Forge project and its native zsh shell plugin.

- Original Forge repository: https://github.com/tailcallhq/forgecode
- Native zsh shell plugin: https://github.com/tailcallhq/forgecode/tree/main/shell-plugin

Use the upstream Forge repository as a reference for Forge behavior, and the shell-plugin directory as a reference for the zsh implementation details that inform this fish integration.

## Files

- `setup.fish`
- `~/.config/fish/conf.d/forge.fish`
- `~/.config/fish/completions/forge.fish`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `LICENSE`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/pull_request_template.yml`

## Repository guidelines

- Contributing: `CONTRIBUTING.md`
- Code of conduct: `CODE_OF_CONDUCT.md`
- Security reporting: `SECURITY.md`
- License: `LICENSE`
- Issue templates: `.github/ISSUE_TEMPLATE/`
- Pull request template: `.github/PULL_REQUEST_TEMPLATE.md`

Forge responses appear on their own line so the command flow stays close to the zsh plugin’s editor-driven output separation.

Session state continues to persist across fish shells via universal variables, including conversation, model, provider, reasoning effort, and active agent.

Relevant behavior in the fish integration:
- provider selection and login/logout canonicalization: `.config/fish/conf.d/forge.fish:154-234`, `.config/fish/conf.d/forge.fish:673-701`
- session restoration: `.config/fish/conf.d/forge.fish:4-13`, `.config/fish/conf.d/forge.fish:336-395`, `.config/fish/conf.d/forge.fish:520-609`
- prompt dispatch: `.config/fish/conf.d/forge.fish:743-829`
- fish completions: `.config/fish/completions/forge.fish:1-101`
