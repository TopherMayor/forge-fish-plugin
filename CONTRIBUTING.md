# Contributing

Thank you for helping improve the Forge Fish Plugin.

## Before you start

- Make sure `fish` is installed.
- Clone the repository locally.
- Run `./setup.fish --dry-run` before applying setup changes.
- Run `fish -n .config/fish/conf.d/forge.fish` and `fish -n .config/fish/completions/forge.fish` after changing prompt or completion behavior.
- If you change Tab behavior or picker UX, update the README sections that describe completions and key bindings.

## Local workflow

1. Create a branch.
2. Make your changes.
3. Run a Fish syntax check:

   ```fish
   fish -n setup.fish
   fish -n .config/fish/conf.d/forge.fish
   fish -n .config/fish/completions/forge.fish
   ```

4. Run the setup script in dry-run mode if you changed it:

   ```fish
   ./setup.fish --dry-run
   ```

5. Review `git status` and the diff.
6. Open a pull request against `main`.

## Guidelines

- Keep the repository free of secrets, tokens, and local machine-specific artifacts.
- Prefer small, focused commits.
- Update the README when behavior or setup changes.
- If you change setup behavior, document new flags and prerequisites.

## Reporting issues

Please include:

- the Forge version
- Fish version
- operating system
- the exact command or prompt text used
- any relevant error output

## Code of conduct

Be respectful and constructive in all discussions and reviews.
