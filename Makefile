.PHONY: demo-presenters demo-all-presenters demo-init-presenter demo-track-presenter demo-untrack-presenter demo-commit-presenter demo-autosync-presenter demo-passthrough-presenter demo-problem-presenter demo-usage-presenter test-all-presenters test-presenter-contracts test-passthrough-presenter-contracts test-usage-gitx-presenter-contracts test-autosync-presenter-contracts test-autosync-command-behavior setup-fish

demo-presenters: demo-all-presenters

demo-all-presenters: setup-fish demo-init-presenter demo-track-presenter demo-untrack-presenter demo-commit-presenter demo-autosync-presenter demo-passthrough-presenter demo-problem-presenter demo-usage-presenter

test-all-presenters: setup-fish demo-all-presenters test-presenter-contracts test-autosync-command-behavior
	@echo ""
	@echo "✓ All tests passed successfully"

demo-init-presenter: setup-fish
	@echo "1. INIT PRESENTER"
	@echo "1a. Init - Dry-run mode"
	@echo "-----------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 1 /home/user/.gitx/repos/demo-repo/repo "" demo-repo'
	@echo "1b. Init - Actual mode"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 0 /home/user/.gitx/repos/demo-repo/repo "" demo-repo'
	@echo "1c. Init - Dry-run mode (with remote)"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 1 /home/user/.gitx/repos/demo-repo/repo "git@github.com:user/configs.git" demo-repo'
	@echo "1d. Init - Actual mode (with remote)"
	@echo "------------------------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 0 /home/user/.gitx/repos/demo-repo/repo "git@github.com:user/configs.git" demo-repo'

demo-track-presenter: setup-fish
	@echo "2. TRACK PRESENTER"
	@echo "2a. Track - Dry-run with 3 files"
	@echo "--------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 1 demo-repo 3 /tmp/test1.txt /tmp/test2.txt /tmp/test3.txt'
	@echo "2b. Track - Actual with 3 files (success)"
	@echo "-----------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 0 demo-repo 3 /tmp/test1.txt /tmp/test2.txt /tmp/test3.txt'
	@echo "2c. Track - Dry-run with 0 files (failure case)"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 1 demo-repo 0'
	@echo "2d. Track - Actual with 0 files (failure case)"
	@echo "----------------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 0 demo-repo 0'

demo-untrack-presenter: setup-fish
	@echo "3. UNTRACK PRESENTER"
	@echo "3a. Untrack - Dry-run with 2 files"
	@echo "----------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 1 demo-repo 2 /tmp/utest1.txt /tmp/utest2.txt'
	@echo "3b. Untrack - Actual with 2 files"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 0 demo-repo 2 /tmp/utest1.txt /tmp/utest2.txt'
	@echo "3c. Untrack - Dry-run with 0 files (failure case)"
	@echo "-------------------------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 1 demo-repo 0'
	@echo "3d. Untrack - Actual with 0 files (failure case)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 0 demo-repo 0'

demo-commit-presenter: setup-fish
	@echo "4. COMMIT PRESENTER"
	@echo "4a. Commit - Dry-run with 2 files"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 1 demo-repo 2 "Add test files" /tmp/file1.txt /tmp/file2.txt'
	@echo "4b. Commit - Actual with 2 files (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 0 demo-repo 2 "Update configuration" /tmp/config.txt /tmp/settings.txt'
	@echo "4c. Commit - Dry-run with 0 files (noop)"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 1 demo-repo 0 "Nothing to commit"'
	@echo "4d. Commit - Actual with 0 files (noop)"
	@echo "---------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 0 demo-repo 0 "Nothing to commit"'

demo-autosync-presenter: setup-fish
	@echo "5. AUTOSYNC PRESENTER"
	@echo "5a. Autosync on - Dry-run (all repos)"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync on 1 launchd 15m all'
	@echo "5b. Autosync on - Actual (selected repos)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync on 0 systemd-user 2h selected demo-repo configs'
	@echo "5c. Autosync off - Dry-run"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync off 1 launchd'
	@echo "5d. Autosync off - Actual"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync off 0 systemd-user'
	@echo "5e. Autosync status - Enabled and active"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 launchd 1 1 15m all'
	@echo "5f. Autosync status - Disabled"
	@echo "------------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 systemd-user 0 0 2h selected demo-repo'

demo-passthrough-presenter: setup-fish
	@echo "6. PASSTHROUGH PRESENTER"
	@echo "6a. Passthrough - Single repo success"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo'
	@echo "6b. Passthrough - Single repo failure"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 0 demo-repo'
	@echo "6c. Passthrough - Multiple repos (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo; __gitx_present_passthrough entry-start configs-repo; __gitx_present_passthrough entry-end 1 configs-repo'
	@echo "6d. Passthrough - Multiple repos (mixed results)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo; __gitx_present_passthrough entry-start dotfiles; __gitx_present_passthrough entry-end 0 dotfiles'

demo-problem-presenter: setup-fish
	@echo "7. PROBLEM PRESENTER"
	@echo "7a. gitx - no repos found"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx" "-" 0 "No repos found" "$$HOME/.gitx/repos"'
	@echo "7b. gitx-init - failed to initialize bare repo"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to initialize bare repo" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7c. gitx-init - failed to set remote.origin.url"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set remote.origin.url" "git@github.com:user/configs.git"'
	@echo "7d. gitx-init - failed to set remote.origin.fetch"
	@echo "-------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set remote.origin.fetch"'
	@echo "7e. gitx-init - failed to set status.showUntrackedFiles=no"
	@echo "-----------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set status.showUntrackedFiles=no"'
	@echo "7f. gitx-untrack - repo not found (actual)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7g. gitx-untrack - repo not found (dry-run)"
	@echo "-------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 1 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7h. gitx-untrack - failed to list tracked files (actual)"
	@echo "-------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to list tracked files"'
	@echo "7i. gitx-untrack - failed to list tracked files (dry-run)"
	@echo "--------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 1 "Failed to list tracked files"'
	@echo "7j. gitx-untrack - failed to untrack files from index"
	@echo "-----------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to untrack files from index" "Git rm --cached failed"'
	@echo "7k. gitx-untrack - failed to create exclude backup"
	@echo "--------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to create exclude backup" "$$HOME/.gitx/repos/demo-repo/repo/info/exclude.bak"'
	@echo "7l. gitx-untrack - failed to update exclude file"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to update exclude file" "$$HOME/.gitx/repos/demo-repo/repo/info/exclude"'
	@echo "7m. gitx-track - repo not found (actual)"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-track" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7n. gitx-track - repo not found (dry-run)"
	@echo "-----------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-track" "demo-repo" 1 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7o. gitx-commit - repo not found"
	@echo "--------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "7p. gitx-commit - failed to auto-stage tracked changes"
	@echo "------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Failed to auto-stage tracked changes"'
	@echo "7q. gitx-commit - failed while checking staged changes"
	@echo "------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Failed while checking staged changes"'
	@echo "7r. gitx-commit - commit failed"
	@echo "-------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Commit failed"'
	@echo "7s. gitx-autosync - unsupported platform"
	@echo "-----------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-autosync" "-" 0 "Unsupported platform" "FreeBSD"'

demo-usage-presenter: setup-fish
	@echo "8. USAGE PRESENTER"
	@echo "8a. gitx usage - with available repos"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx with-repos "demo-repo" "configs-repo"'
	@echo "8b. gitx usage - single repo missing git args"
	@echo "---------------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-git-args "demo-repo"'
	@echo "8c. gitx usage - no repos found"
	@echo "-------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos "$$HOME/.gitx/repos"'
	@echo "8d. gitx usage - repos directory missing"
	@echo "---------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx missing-repos-dir "$$HOME/.gitx/repos"'
	@echo "8e. gitx-init usage"
	@echo "-------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-init" "gitx-init [--dry-run] <repo> [remote-url]"'
	@echo "8f. gitx-track usage"
	@echo "--------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-track" "gitx-track [--dry-run] <repo> <file> [file ...]"'
	@echo "8g. gitx-untrack usage"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-untrack" "gitx-untrack [--dry-run] <repo> <file> [file ...]"'
	@echo "8h. gitx-commit usage"
	@echo "---------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-commit" "gitx-commit [--dry-run] <repo> [-m|--message <text>]"'
	@echo "8i. gitx-autosync usage"
	@echo "------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-autosync" "gitx-autosync [--dry-run] on [--every <duration>] [--repo <name> ...]" "gitx-autosync [--dry-run] off" "gitx-autosync [--dry-run] status"'

test-presenter-contracts: setup-fish test-passthrough-presenter-contracts test-usage-gitx-presenter-contracts test-autosync-presenter-contracts

test-passthrough-presenter-contracts: setup-fish
	@echo "9. PASSTHROUGH PRESENTER CONTRACTS"
	@echo "9a. Missing mode argument"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough' 2>&1 | rg -F "Error: __gitx_present_passthrough requires at least 1 argument" || exit 1
	@echo "9b. Unknown mode"
	@echo "----------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough invalid-mode' 2>&1 | rg -F "Error: __gitx_present_passthrough unknown mode: invalid-mode" || exit 1
	@echo "9c. begin with extra args"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin extra' 2>&1 | rg -F "Error: __gitx_present_passthrough begin takes no extra arguments" || exit 1
	@echo "9d. entry-start missing repo"
	@echo "----------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-start' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-start requires exactly 1 argument" || exit 1
	@echo "9e. entry-end missing args"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-end' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-end requires exactly 2 arguments" || exit 1
	@echo "9f. entry-end invalid success"
	@echo "-----------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-end 2 demo-repo' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-end success must be 0 or 1" || exit 1
	@echo ""
	@echo "  ✓ All passthrough presenter contract tests passed"

test-usage-gitx-presenter-contracts: setup-fish
	@echo "10. USAGE GITX PRESENTER CONTRACTS"
	@echo "10a. Missing mode argument"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx' 2>&1 | rg -F "Error: __gitx_present_usage_gitx requires at least 1 argument" || exit 1
	@echo "10b. Unknown mode"
	@echo "----------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx bad-mode' 2>&1 | rg -F "Error: __gitx_present_usage_gitx unknown mode: bad-mode" || exit 1
	@echo "10c. with-repos missing repo names"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx with-repos' 2>&1 | rg -F "Error: __gitx_present_usage_gitx with-repos requires at least 1 repo name" || exit 1
	@echo "10d. no-repos missing path"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-repos requires exactly 1 path argument" || exit 1
	@echo "10e. no-repos extra arg"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos /tmp extra' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-repos requires exactly 1 path argument" || exit 1
	@echo "10f. missing-repos-dir wrong arity"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx missing-repos-dir' 2>&1 | rg -F "Error: __gitx_present_usage_gitx missing-repos-dir requires exactly 1 path argument" || exit 1
	@echo "10g. no-git-args wrong arity"
	@echo "---------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-git-args' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-git-args requires exactly 1 repo name argument" || exit 1
	@echo ""
	@echo "  ✓ All usage gitx presenter contract tests passed"

test-autosync-presenter-contracts: setup-fish
	@echo "11. AUTOSYNC PRESENTER CONTRACTS"
	@echo "11a. Missing mode argument"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync' 2>&1 | rg -F "Error: __gitx_present_autosync requires at least 1 argument" || exit 1
	@echo "11b. Unknown mode"
	@echo "-----------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync invalid-mode' 2>&1 | rg -F "Error: __gitx_present_autosync unknown mode: invalid-mode" || exit 1
	@echo "11c. on missing arguments"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync on' 2>&1 | rg -F "Error: __gitx_present_autosync on requires at least 4 arguments" || exit 1
	@echo "11d. on invalid dry_run"
	@echo "-----------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync on 2 launchd 15m all' 2>&1 | rg -F "Error: __gitx_present_autosync on dry_run must be 0 or 1" || exit 1
	@echo "11e. off wrong arity"
	@echo "--------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync off 1' 2>&1 | rg -F "Error: __gitx_present_autosync off requires exactly 2 arguments" || exit 1
	@echo "11f. status missing arguments"
	@echo "-----------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 launchd 1 1 15m' 2>&1 | rg -F "Error: __gitx_present_autosync status requires at least 6 arguments" || exit 1
	@echo "11g. status invalid enabled"
	@echo "---------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 launchd 2 1 15m all' 2>&1 | rg -F "Error: __gitx_present_autosync status enabled must be 0 or 1" || exit 1
	@echo "11h. status invalid active"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 launchd 1 2 15m all' 2>&1 | rg -F "Error: __gitx_present_autosync status active must be 0 or 1" || exit 1
	@echo "11i. status warns on active while disabled"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_autosync.fish; __gitx_present_autosync status 0 launchd 0 1 15m all' 2>&1 | rg -F "Active while disabled." || exit 1
	@echo ""
	@echo "  ✓ All autosync presenter contract tests passed"

test-autosync-command-behavior: setup-fish
	@echo "12. AUTOSYNC COMMAND BEHAVIOR"
	@echo "12a. Invalid --every rejects unsupported units"
	@echo "----------------------------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync on --every 30s' 2>&1 | rg -F "Invalid --every value" || exit 1
	@echo "12b. --all is rejected as unknown flag"
	@echo "--------------------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync on --all' 2>&1 | rg -F -- "--all: unknown option" || exit 1
	@echo "12c. Linux hard-fail when systemd --user unavailable"
	@echo "----------------------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/bin" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'echo Linux' > "$$tmpdir/bin/uname" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'if [ "$$1" = "--user" ] && [ "$$2" = "show-environment" ]; then exit 1; fi' 'exit 0' > "$$tmpdir/bin/systemctl" && \
	command chmod +x "$$tmpdir/bin/uname" "$$tmpdir/bin/systemctl" && \
	PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync on' 2>&1 | rg -F "systemd --user is unavailable" || { command rm -rf "$$tmpdir"; exit 1; } && \
	command rm -rf "$$tmpdir"
	@echo "12d. Repeated --repo values are all honored"
	@echo "--------------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/bin" "$$tmpdir/.gitx/repos/work/repo" "$$tmpdir/.gitx/repos/settings/repo" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'echo Darwin' > "$$tmpdir/bin/uname" && \
	command chmod +x "$$tmpdir/bin/uname" && \
	HOME="$$tmpdir" PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync on --dry-run --repo work --repo settings' 2>&1 | rg -F "work" || { command rm -rf "$$tmpdir"; exit 1; } && \
	HOME="$$tmpdir" PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync on --dry-run --repo work --repo settings' 2>&1 | rg -F "settings" || { command rm -rf "$$tmpdir"; exit 1; } && \
	command rm -rf "$$tmpdir"
	@echo "12e. off fails when launchd disable fails"
	@echo "-----------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/bin" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'echo Darwin' > "$$tmpdir/bin/uname" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'if [ "$$1" = "print" ]; then exit 1; fi' 'if [ "$$1" = "disable" ]; then exit 1; fi' 'if [ "$$1" = "print-disabled" ]; then exit 0; fi' 'exit 0' > "$$tmpdir/bin/launchctl" && \
	command chmod +x "$$tmpdir/bin/uname" "$$tmpdir/bin/launchctl" && \
	HOME="$$tmpdir" PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync off' 2>&1 | rg -F "Failed to disable launchd agent" || { command rm -rf "$$tmpdir"; exit 1; } && \
	command rm -rf "$$tmpdir"
	@echo "12f. status fails on invalid selected config"
	@echo "--------------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/bin" "$$tmpdir/.gitx/autosync" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'echo Darwin' > "$$tmpdir/bin/uname" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'if [ "$$1" = "print" ]; then exit 1; fi' 'if [ "$$1" = "print-disabled" ]; then exit 0; fi' 'exit 0' > "$$tmpdir/bin/launchctl" && \
	command printf '%s\n' 'enabled=1' 'every=1m' 'scope=selected' 'repos=' 'backend=launchd' > "$$tmpdir/.gitx/autosync/config" && \
	command chmod +x "$$tmpdir/bin/uname" "$$tmpdir/bin/launchctl" && \
	HOME="$$tmpdir" PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync status' 2>&1 | rg -F "Invalid autosync config" || { command rm -rf "$$tmpdir"; exit 1; } && \
	command rm -rf "$$tmpdir"
	@echo "12g. off succeeds on Linux before first on"
	@echo "------------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/bin" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'echo Linux' > "$$tmpdir/bin/uname" && \
	command printf '%s\n' '#!/usr/bin/env bash' 'if [ "$$1" = "--user" ] && [ "$$2" = "show-environment" ]; then exit 0; fi' 'if [ "$$1" = "--user" ] && [ "$$2" = "disable" ]; then exit 42; fi' 'exit 0' > "$$tmpdir/bin/systemctl" && \
	command chmod +x "$$tmpdir/bin/uname" "$$tmpdir/bin/systemctl" && \
	HOME="$$tmpdir" PATH="$$tmpdir/bin:$$PATH" fish -c 'source functions/__gitx_present_usage.fish; source functions/__gitx_present_problem.fish; source functions/__gitx_present_autosync.fish; source functions/gitx-autosync.fish; gitx-autosync off' 2>&1 | rg -F "Autosync disabled" || { command rm -rf "$$tmpdir"; exit 1; } && \
	command rm -rf "$$tmpdir"
	@echo "12h. runner executes without loading user config"
	@echo "-----------------------------------------------"
	@tmpdir=$$(mktemp -d) && \
	command mkdir -p "$$tmpdir/.config/fish/functions" "$$tmpdir/.gitx/autosync" && \
	command printf '%s\n' 'command printf "%s\n" "loaded" > "$$HOME/config-loaded"' > "$$tmpdir/.config/fish/config.fish" && \
	command printf '%s\n' 'function __gitx_autosync_run' '    gitx-commit' 'end' > "$$tmpdir/.config/fish/functions/__gitx_autosync_run.fish" && \
	command printf '%s\n' 'function gitx-commit' '    command printf "%s\n" "ran" > "$$HOME/runner-ran"' 'end' > "$$tmpdir/.config/fish/functions/gitx-commit.fish" && \
	HOME="$$tmpdir" fish --no-config -c 'source functions/gitx-autosync.fish; __gitx_autosync_write_runner "$$HOME/.gitx/autosync/run.fish"; __gitx_autosync_write_systemd_units "$$HOME/.config/systemd/user/gitx-autosync.service" "$$HOME/.config/systemd/user/gitx-autosync.timer" "$$HOME/.gitx/autosync/run.fish" "15m" "/usr/local/bin/fish"' || { command rm -rf "$$tmpdir"; exit 1; } && \
	rg -F -- "--no-config" "$$tmpdir/.config/systemd/user/gitx-autosync.service" >/dev/null || { command rm -rf "$$tmpdir"; exit 1; } && \
	HOME="$$tmpdir" fish --no-config "$$tmpdir/.gitx/autosync/run.fish" >/dev/null 2>/dev/null || { command rm -rf "$$tmpdir"; exit 1; } && \
	command test -f "$$tmpdir/runner-ran" || { command rm -rf "$$tmpdir"; exit 1; } && \
	if command test -f "$$tmpdir/config-loaded"; then command rm -rf "$$tmpdir"; exit 1; fi && \
	command rm -rf "$$tmpdir"
	@echo ""
	@echo "  ✓ Autosync command behavior checks passed"

setup-fish:
	@command -v fish >/dev/null 2>&1 || { echo "Installing fish shell..."; sudo apt-get update -qq && sudo apt-get install -y -qq fish > /dev/null 2>&1; }
