# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Version control

This repo uses [Jujutsu](https://github.com/jj-vcs/jj) (`jj`), not raw git. Use `jj` commands (`jj st`, `jj diff`, `jj describe`, `jj new`, `jj git push`, etc.) for all VCS operations instead of `git`.

## Commands

```bash
just strap              # Run full setup (bootstrap.sh -> strap/setup.fish)
just strap <stage>      # Run a single stage: fonts, config, data, dotfiles, tools, scripts, neovim
just docker             # Build Docker dev environment image (also what CI builds)
just update             # Pull latest changes in the private submodule
lua tests/noctalia-cloudbuild.lua   # Only test: mocked-host test of the noctalia cloudbuild plugin (run from repo root)
```

There is no general test suite or linter; validate by running the affected stage (`just strap config` after config edits, `just strap tools` after installer changes) and checking the installed target under `$HOME`.

The `bootstrap.sh` entry point handles OS detection (Ubuntu/Arch/macOS) before delegating to `strap/setup.fish` written in Fish.

## Architecture

### How configuration is installed

All configs use envsubst-based copying rather than plain symlinks. `strap/lib.fish:install_tree` walks a source tree and, for each file, `install_file` substitutes variables from the `VARIABLES` file (using `envsubst`), applies any platform layers, writes the result to the target path, then preserves the executable bit if set. "Symlink" in the codebase means this substitution+copy, not an actual filesystem symlink.

The `VARIABLES` file defines the substitutable values (terminal font, music dir, etc.). Only the variables listed in it are substituted, so a new `${FOO}` in a config must also be added to `VARIABLES` (and to the `justfile` defaults). Customize these before running strap.

### Setup stages (`strap/setup.fish`)

Each stage has a corresponding `strap/<stage>.fish` file:

| Stage | Source | Target |
|-------|--------|--------|
| `config` | `config/*/` | `$HOME/.config/` |
| `dotfiles` | `dotfiles/*/` | `$HOME/.<name>` |
| `data` | `data/*/` | `$XDG_DATA_HOME/` |
| `scripts` | `scripts/*/` | `$HOME/scripts/` |
| `fonts` | `fonts/*/` | `~/.local/share/fonts/` (Linux) or `~/Library/Fonts/` (macOS) |

The `private/` git submodule mirrors the same directory structure and is processed by the same setup functions after the main repo.

### Platform-specific files

Any file or directory in `config/`, `data/`, `dotfiles/` or `scripts/` may carry a platform tag as a name suffix: `.linux`, `.macos`, `.arch`, `.ubuntu`. The tag is stripped from the installed path, and the file is skipped entirely on other platforms (a tagged directory skips everything under it).

```
config/niri.linux/config.kdl   ->  ~/.config/niri/config.kdl   (Linux only)
scripts/util/pbcopy.macos      ->  ~/scripts/util/pbcopy       (macOS only)
```

When a tagged file sits next to an untagged file of the same name, it is a **layer** of that file rather than a standalone file: the base is installed everywhere and the matching layer is merged on top. This is how a mostly-shared config keeps a couple of OS-specific lines:

```
config/ghostty/config          ->  installed everywhere
config/ghostty/config.linux    ->  appended to it on Linux only
```

### Merge strategies

`install_file` picks how a layer is combined based on the target's extension:

- `.json` — deep merge via `jq` (the layer wins on conflicts; a top-level array is replaced wholesale). JSON targets are also merged **over whatever is already installed**, so settings an app wrote to its own config file (e.g. Zed's `agent_servers`) survive a strap run. The flip side: deleting a key from the repo no longer deletes it from the installed file.
- everything else — the layer is appended to the base, which suits the last-value-wins line configs (ghostty, etc.). The target is fully replaced on every run.

When a JSON merge fails (the installed file isn't parseable — Zed writing JSONC comments, say), strap never drops the app's own state silently: it copies the target to `<target>.strap-bak`, writes the repo version, and warns. `jq` is pulled in on demand by `merge_strategy`, since the config stages run before the tool stage on a fresh machine.

### Tool installation (`strap/installers/`)

`strap/tools.fish` runs `ensure_installed` for every file in `strap/installers/`. Installers are extensionless fish scripts (e.g. `strap/installers/rg`) that branch on `is_ubuntu` / `is_arch` / `is_mac` and use the native package manager; `ensure_installed` skips tools already on `PATH`. The `scripts/pkg/install` script is a generic GitHub-release binary downloader (uses `gh` CLI) — use it to add new tools that publish releases on GitHub rather than writing custom installers when possible.

### Fish shell config (`config/fish/`)

- `conf.d/` — auto-loaded config modules (tools init, aliases, path, platform-specific)
- `functions/` — Fish functions
- `completions/` — Tab completions

### Other notable areas

- `config/nushell/` — nushell is the interactive shell; custom modules live in `modules/` (`stdx`, `emu`).
- `data/noctalia.linux/plugins/` — Luau plugins for the noctalia shell (cloudbuild, pueue, games, projects), installed to `$XDG_DATA_HOME/noctalia/plugins`.
- `dotfiles/claude/` — installs to `~/.claude`, i.e. the user-level Claude Code skills (`cpp`, `ui-conventions`) are managed from this repo.

## Key files

- `VARIABLES` — environment variables substituted into all config files at install time
- `justfile` — task runner (requires [just](https://github.com/casey/just))
- `private/` — git submodule (`dalloriam/dotfiles-private`) for sensitive/machine-specific config
- `.github/workflows/image.yml` — builds and pushes `ghcr.io/dalloriam/dotfiles/devenv-base:latest` on every push to master
