# gitx

> `gitx` helps you version files that live in very different places on your machine in one or more git/GitHub repos.

Imagine a **dynamic** repo, unconstrained by a single root directory, a **composition** of files from different places.

You can use it to version anything, but a very common use is for things like:
- Shell configs
  - `~/.config/fish`
  - `~/.zshrc`
- Tool configs
  - `~/.config/opencode/opencode.json*` (OpenCode CLI)
  - `~/.codex/config.toml` (OpenAI Codex CLI)
  - `~/.claude.json` (Claude Code CLI)
  - `~/Library/Application Support/JetBrains/**/keymaps/*` (JetBrains IDEs)
- `.env` files
  - `~/**/.env`
  - `~/**/.env.*`
- Any other files you want to keep track but don't want to keep copying to another path

The secret sauce is bare git repos under `~/.gitx/repos/<repo>/repo`, with `/` as the work tree.

- You can create **unlimited** repos tracking different things and even track **the same file in different repos**
- You can track anything anywhere in your machine, even outside your `$HOME` profile, i.e., `/etc/hosts`

## Single requirement

You'll need some [fish 🐠](https://fishshell.com/)

#### macOS
```sh
brew install fish
```

#### Linux / Windows WSL
```sh
sudo apt-add-repository ppa:fish-shell/release-4
sudo apt update
sudo apt install fish
```

Other platforms/installation methods: [github.com/fish-shell/fish-shell](https://github.com/fish-shell/fish-shell?tab=readme-ov-file#getting-fish)

## Installing gitx

1. Copy the gitx files into your Fish config directories and reload:

```sh
git clone git@github.com:that-lucas/gitx.git # or HTTPS
# git clone https://github.com/that-lucas/gitx

cp gitx/functions/*.fish   ~/.config/fish/functions/
cp gitx/completions/*.fish ~/.config/fish/completions/

source ~/.config/fish/config.fish
```

2. Optional: For immediate command descriptions in completion menus, add this to `~/.config/fish/config.fish`:

```sh
functions gitx gitx-init gitx-track gitx-untrack gitx-commit gitx-autosync >/dev/null 2>/dev/null
```

and reload with `source ~/.config/fish/config.fish` or simply run

```sh
echo 'functions gitx gitx-init gitx-track gitx-untrack gitx-commit gitx-autosync >/dev/null 2>/dev/null' >> ~/.config/fish/config.fish

source ~/.config/fish/config.fish
```

## Start with `--dry-run`

Dry run shows you exactly what will happen if you run the same command without the flag. It's a great way to get familiar with the commands and understand their effects.

### Command summary

```sh
gitx-init    --dry-run <repo> [remote-url]     # Create/setup repo
gitx-track   --dry-run <repo> <glob> [glob-n]  # Start tracking files
gitx-untrack --dry-run <repo> <glob> [glob-n]  # Stop tracking files
gitx-commit  --dry-run <repo> [-m "<message>"] # Commit tracked changes
gitx-autosync --dry-run on [--every <duration>] [--repo <name> ...] # Configure periodic commit + push
gitx-autosync --dry-run off                    # Disable periodic sync
gitx-autosync --dry-run status                 # Show periodic sync status
gitx                   <repo> <git-args...>    # Run raw git command for one repo
gitx                          <git-args...>    # Run raw git command across all repos
```

Remove `--dry-run` to actually execute the commands.

Every `gitx` command includes Fish auto-completion. Command modes, flags, common values (e.g., `gitx-autosync` mode aliases and `--every` interval suggestions) and even dynamic values such as the `gitx` repo names you'll create.

## Basic workflow

- Initialize a repo
- Track files you care about (and untrack those you don't want)
  - Commit changes and, optionally, push to remote, or
  - Set `gitx-autosync` to do it for you periodically

## Autosync (every 15m by default)

`gitx-autosync` runs `gitx-commit` and `gitx <repo> push` (if a remote is set) periodically.

- `on|true|1`: enable autosync
- `off|false|0`: disable autosync
- `status`: show enabled/active state plus current config

Examples:

```sh
# All repos every 15 minutes (default)
gitx-autosync on

# One or more repos every 2 hours
gitx-autosync on --every 2h --repo configs --repo dotfiles

# Disable autosync
gitx-autosync off

# Check current state
gitx-autosync status
```

Platform backends:

- macOS: `launchd` user agent
- Linux: `systemd --user` timer/service

## Quick recipe (GitHub with `gh` CLI + `gitx`)

Create a GitHub repo with the `gh` CLI
```sh
gh repo create your-user/configs --private
```
or manually at https://github.com/new, then

```sh
gitx-init   configs git@github.com:your-user/configs.git           # Initialize configs repo
gitx-track  configs ~/.gitconfig ~/.config/opencode/opencode.jsonc # Track a few files
gitx-commit configs                                                # Optional message [-m "Tracking local configs"] # Commit
gitx        configs push                                           # Push
```

## Globs

You can pass multiple files at once, including shell globs that expand to files.

```sh
gitx-track  configs ~/**/*.env ~/**/*.env.*
```

## Autocomplete

Fish completions are included for all `gitx` commands and options: repo names from repos created with `gitx-init`, command modes/aliases (`on|true|1`, `off|false|0`, `status`), flags like `--dry-run`, `--repo`, `--message`, and common values such as `--every` interval suggestions.
