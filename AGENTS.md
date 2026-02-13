# AGENTS.md - Guidelines for AI Agents

## Project Overview

`gitx` is a Fish shell utility for versioning files from different places on a machine into one or more git repos.

- Language: Fish shell scripts (`.fish`)
- Runtime: interpreted (no compile/build step)
- Repo model: bare repos under `~/.gitx/repos/<repo>/repo`, work tree `/`
- Main commands: `gitx`, `gitx-init`, `gitx-track`, `gitx-untrack`, `gitx-commit`

## Build, Test, and Dev Commands

There is no build pipeline for binaries. Development is test/demo oriented.

```bash
# Fast pass/fail checks (recommended during development)
make test-presenter-contracts

# Targeted suites
make test-passthrough-presenter-contracts
make test-usage-gitx-presenter-contracts

# Full run (very verbose: demos + contracts)
make test-all-presenters

# Visual/demo output only
make demo-presenters
make demo-init-presenter
make demo-track-presenter
make demo-untrack-presenter
make demo-commit-presenter
make demo-passthrough-presenter
make demo-problem-presenter
make demo-usage-presenter
```

### Which Test Target to Run

- `make test-passthrough-presenter-contracts`: Runs only passthrough presenter contract assertions.
- `make test-usage-gitx-presenter-contracts`: Runs only usage presenter contract assertions.
- `make test-presenter-contracts`: Runs both contract suites; use as the default fast gate.
- `make test-all-presenters`: Runs demos plus contract suites; use for end-to-end confidence when presenter output changes.
- Rule of thumb: run targeted suite(s) first, then `make test-presenter-contracts`, and only run `make test-all-presenters` when broad output/presenter behavior changed.

### Single Test Execution

The project does not use a unit-test framework runner. Run one assertion directly with `fish` + `rg`.

```bash
fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough' 2>&1 \
  | rg -F "Error: __gitx_present_passthrough requires at least 1 argument"
```

- If `rg` finds the expected text: exit code `0` (pass)
- If it does not: exit code `1` (fail)

### Test Output Expectations

- `make test-all-presenters` is intentionally noisy because it includes all demo presenters.
- Contract tests are strict assertions (`rg -F ... || exit 1`) and fail the target on mismatch.
- Success markers at the end:
  - `✓ All passthrough presenter contract tests passed`
  - `✓ All usage gitx presenter contract tests passed`
  - `✓ All tests passed successfully`
- On failure, `make` prints `Error 1` and exits non-zero.

## Code Style Guidelines

## Naming and Layout

- Main command files: `functions/gitx*.fish`
- Presenter files: `functions/__gitx_present_<name>.fish`
- Completion files: `completions/<command>.fish`
- Function names mirror command names or presenter filenames.

## Variables and Scope

- Prefer descriptive snake_case names (`repo_name`, `dry_run`, `items_count`).
- Use `set -l` for local scope by default.
- Keep related names grouped (`repo_*`, `success_*`, etc.).

## Args and Control Flow

- Validate arity early with `count $argv`.
- Assign validated args to named locals immediately.
- Use early `return 1` for invalid input paths.

## Command Execution and Errors

- Use `command` prefix for external tools to avoid function recursion.
- Capture status immediately after command execution:
  - `command <cmd>`
  - `set -l rc $status`
- Send errors to stderr using `echo "Error: ..." >&2`.

## Output and Presentation

- Presenters own user-facing output.
- Use `set_color` + reset with `set_color normal`.
- Color conventions:
  - `green`: success
  - `cyan`: informational/usage/next steps
  - `brblack`: dry-run output
  - `red`: errors/problems
- Symbol conventions:
  - `✓` success
  - `◉` dry-run indicator
  - `✗` failure

## Descriptions and Completions

- Keep function `--description` and completion `-d` text aligned in intent.
- Use user-goal wording (what command does) over internal implementation details.
- Current command descriptions:
  - `gitx`: Run git commands against a gitx repo or all of them at once
  - `gitx-init`: Create a new gitx repo that can track files from anywhere on your system
  - `gitx-track`: Add files to a gitx repo so they start being tracked
  - `gitx-untrack`: Stop tracking files from a gitx repo
  - `gitx-commit`: Commit files changed - if any - with an optional message

- Current dry-run descriptions:
  - `gitx-init --dry-run`: Preview what would happen without making changes
  - `gitx-track --dry-run`: Preview which files would be tracked
  - `gitx-untrack --dry-run`: Preview which files would stop being tracked
  - `gitx-commit --dry-run`: Preview what would be committed

## Key Patterns to Follow

1. Validate argument count at function start.
2. Use `--description` on all functions.
3. Quote variable expansions (`"$repo"`, `"$argv[1]"`).
4. Prefer `test` for conditionals (`test $dry_run -eq 1`).
5. Keep presenter output consistent with existing visual style.

## Project Structure

```text
functions/
  gitx.fish
  gitx-init.fish
  gitx-track.fish
  gitx-untrack.fish
  gitx-commit.fish
  __gitx_present_*.fish
completions/
  *.fish
Makefile
README.md
```

## Rules Files

- No `.cursor/rules/` directory found.
- No `.cursorrules` file found.
- No `.github/copilot-instructions.md` file found.

## Git and Artifact Hygiene

- Keep commits focused; avoid unrelated refactors.
- Do not commit generated artifacts (logs, caches, temp files, `.venv`, local env files, demo output captures) unless explicitly requested.
- Treat presenter/output wording changes as user-facing changes; keep them isolated from logic changes when possible.
- Before pushing, run relevant test gates for touched areas:
  - Minimum: `make test-presenter-contracts`
  - If presenter output changed: run targeted suite(s) and consider `make test-all-presenters` for end-to-end confidence.

## Development Workflow (Required)

- Never commit directly to `main`.
- Always create a feature/fix branch before committing (for example: `feat/...`, `fix/...`, `chore/...`).
- Push the branch and open a PR for every code change.
- Treat PR creation as the review gate; do not merge before review feedback.
- After review, address comments with follow-up commits on the same branch.
- Re-run relevant tests after each review-driven update before pushing again.

## Important Notes

- No traditional linting tool is configured.
- No enforced formatter is configured (optional: `fish_indent`).
- `--dry-run` should be supported for all mutating commands.
- Favor small, behavior-preserving changes unless explicitly asked otherwise.
