# Forge Fish Plugin

Forge's fish integration for prompt dispatch, command helpers, pickers, completions, and session persistence. This project is an independent, unaffiliated project that sits alongside the Forge project.

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

That `forge zsh plugin` command comes from Forge itself; it prints the zsh shell-plugin integration script, which the native zsh setup typically evals inside `.zshrc`.

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
  - delete
  - resume
  - stats
  - copy
  - dump
  - compact
  - retry
- Model and provider pickers
- Configuration helpers for model, commit model, suggest model, and reasoning effort
- Workspace helpers
- Commit, suggestion, logs, update, MCP, custom-command, and VS Code helpers
- Session state persists across fish shells via universal variables, including conversation, model, provider, reasoning effort, and active agent
- Provider login/logout picker selections resolve to Forge provider IDs, so the fish plugin uses the same identifier whether you choose a provider by name or ID

## Feature parity with the native zsh plugin

The fish plugin is functionally close to the native zsh plugin, while remaining a separate fish-native integration.

### Parity matrix

| Area | Fish plugin | Native zsh plugin | Status |
|---|---|---|---|
| Prompt-command dispatch | `:` commands are parsed and routed in the fish dispatcher | zsh uses editor widgets and shell-line transformation | **Supported** for the core workflow, **Partial** for mechanics |
| `:new` | Starts a fresh conversation and resets active agent | Same user-facing behavior | **Supported** |
| `:info` / `:help` | Dispatches to Forge info/help flows | Same conceptual commands exist | **Supported** |
| `:agent` | Opens a picker and updates the active agent | Native agent selection helpers | **Supported** |
| Bare agent commands | `:forge`, `:muse`, `:sage`, and similar agent switches work directly | Agent-style prompt commands are available upstream | **Supported** |
| `:conversation` | Switch, clone, rename, copy, dump, compact, retry, resume, stats, and delete workflows exist | Same general conversation workflow | **Supported** |
| `:model` / `:config-model` | Model picker and model config helpers exist | Upstream has model selection/config helpers | **Supported** |
| `:reasoning-effort` | Reasoning effort picker/config exists | Upstream has session/config controls | **Supported** |
| `:provider-login` / `:logout` | Provider login/logout resolves canonical provider IDs | Upstream uses provider selection/login flows | **Supported** |
| `:logs` | Streams logs or forwards log flags to Forge | Upstream has log-streaming commands | **Supported** |
| `:mcp` | Routes MCP subcommands such as list/import/remove/show/reload/login/logout | Upstream has MCP server management commands | **Supported** |
| `:cmd` | Routes custom command list/execute flows | Upstream has custom command management | **Supported** |
| `:update` | Forwards update flags such as `--no-confirm` | Upstream includes update workflows | **Supported** |
| `:vscode` | Routes VS Code extension install helpers | Upstream includes editor integration commands | **Supported** |
| Workspace commands | `:workspace-sync` / `:sync`, `:workspace-init`, `:workspace-status`, and `:workspace-info` are implemented | Upstream documents workspace-oriented commands | **Supported** |
| Commit helpers | `:commit` and `:commit-preview` are implemented | Upstream includes commit-generation flow | **Supported** |
| Suggestion helpers | `:suggest` exists | Upstream includes suggestion-style actions | **Supported** |
| Configuration commands | `:config`, `:config-edit`, `:config-reload`, `:config-commit-model`, `:config-suggest-model`, and related config flows exist | Upstream has config management flows | **Supported** |
| `:skill` / `:tools` | Present in the fish dispatcher | Upstream has tool/workflow-oriented commands | **Supported** |
| Session continuity | Conversation, model, provider, reasoning effort, and active agent persist across fish shells via universal variables | Upstream keeps context within the current shell/plugin session | **Supported** for continuity, **Different** in implementation |
| Prompt/status display | Fish right prompt shows Forge status, active agent, model, effort, and conversation id | Upstream uses shell-theme/RPROMPT styling | **Partial** |
| Selectors | Fish provides pickers for conversations, models, providers, and agents | Upstream has native selection helpers | **Partial** |
| Fish completions | Covers root commands, help targets, conversation, provider, MCP, custom command, VS Code, zsh helpers, workspace helpers, and key flags | Upstream has a richer generated completion tree | **Partial** |
| Key bindings | Enter, Tab, Ctrl-J, and Ctrl-V are bound for Forge actions | Upstream uses `zle`-based bindings | **Partial** |
| File tagging `@[...]` | Dedicated fish UX exists for tagged file selection and insertion | Upstream documents interactive file tagging | **Supported** |
| Syntax highlighting | Lightweight live hints are shown for tags and workflow/command prefixes | Upstream provides richer visual feedback for commands and tags | **Partial** |
| `:sync` / codebase indexing | Implemented in the fish dispatcher and documented in completions | Upstream documents codebase indexing | **Supported** |
| `:doctor` diagnostics | Implemented in the fish dispatcher and supported by completions | Upstream documents environment diagnostics | **Supported** |
| `zle`-native editor integration | Fish uses `commandline` and `bind` handlers | Upstream uses true ZLE widgets | **Missing by design** |


The biggest completion gaps are:

- deeper nested subcommand trees
- richer argument completion for prompt commands
- value completion for model, provider, conversation, and agent arguments
- more exhaustive `forge zsh` helper coverage

### Editor needs

The biggest editor gaps are:

- zsh `zle` widgets are more native than fish `commandline` handlers
- fish can submit and rewrite lines, but it does not share zsh’s editor model
- picker cancellations and cursor restoration can still feel less integrated than zsh

### What users can do now

The current fish plugin already supports the main day-to-day workflow:

- start Forge
- submit prompt commands directly
- use `:new` and `:agent`
- switch conversations
- resume, inspect stats, clone, rename, copy, dump, compact, and delete conversations
- choose models and providers
- use workspace helpers
- manage logs, MCP servers, custom commands, updates, and VS Code extension installation
- keep state across shell sessions
- get common Forge completions

These behaviors are reflected in the fish integration and README here:

- `repos/forge-fish-plugin/.config/fish/conf.d/forge.fish:776-837`
- `repos/forge-fish-plugin/.config/fish/conf.d/forge.fish:971-1035`
- `repos/forge-fish-plugin/.config/fish/conf.d/forge.fish:316-334`
- `repos/forge-fish-plugin/.config/fish/completions/forge.fish:1-157`

## Upstream references

This project is an independent, unaffiliated integration that sits alongside the Forge project and its native zsh shell plugin.

- Original Forge repository: https://github.com/tailcallhq/forgecode
- Native zsh shell plugin: https://github.com/tailcallhq/forgecode/tree/main/shell-plugin

Use the Forge repository as a reference for Forge behavior, and the shell-plugin directory as a reference for the zsh implementation details that inform this fish integration.

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
- `.github/PULL_REQUEST_TEMPLATE.md`

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
- prompt dispatch: `.config/fish/conf.d/forge.fish:955-1035`
- fish completions: `.config/fish/completions/forge.fish:1-157`
