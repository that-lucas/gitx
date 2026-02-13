.PHONY: demo-presenters demo-all-presenters demo-init-presenter demo-track-presenter demo-untrack-presenter demo-commit-presenter demo-passthrough-presenter demo-problem-presenter demo-usage-presenter test-all-presenters test-presenter-contracts test-passthrough-presenter-contracts test-usage-gitx-presenter-contracts setup-fish

demo-presenters: demo-all-presenters

demo-all-presenters: setup-fish demo-init-presenter demo-track-presenter demo-untrack-presenter demo-commit-presenter demo-passthrough-presenter demo-problem-presenter demo-usage-presenter

test-all-presenters: setup-fish demo-all-presenters test-presenter-contracts
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

demo-passthrough-presenter: setup-fish
	@echo "5. PASSTHROUGH PRESENTER"
	@echo "5a. Passthrough - Single repo success"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo'
	@echo "5b. Passthrough - Single repo failure"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 0 demo-repo'
	@echo "5c. Passthrough - Multiple repos (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo; __gitx_present_passthrough entry-start configs-repo; __gitx_present_passthrough entry-end 1 configs-repo'
	@echo "5d. Passthrough - Multiple repos (mixed results)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin; __gitx_present_passthrough entry-start demo-repo; __gitx_present_passthrough entry-end 1 demo-repo; __gitx_present_passthrough entry-start dotfiles; __gitx_present_passthrough entry-end 0 dotfiles'

demo-problem-presenter: setup-fish
	@echo "6. PROBLEM PRESENTER"
	@echo "6a. gitx - no repos found"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx" "-" 0 "No repos found" "$$HOME/.gitx/repos"'
	@echo "6b. gitx-init - failed to initialize bare repo"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to initialize bare repo" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6c. gitx-init - failed to set remote.origin.url"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set remote.origin.url" "git@github.com:user/configs.git"'
	@echo "6d. gitx-init - failed to set remote.origin.fetch"
	@echo "-------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set remote.origin.fetch"'
	@echo "6e. gitx-init - failed to set status.showUntrackedFiles=no"
	@echo "-----------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-init" "demo-repo" 0 "Failed to set status.showUntrackedFiles=no"'
	@echo "6f. gitx-untrack - repo not found (actual)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6g. gitx-untrack - repo not found (dry-run)"
	@echo "-------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 1 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6h. gitx-untrack - failed to list tracked files (actual)"
	@echo "-------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to list tracked files"'
	@echo "6i. gitx-untrack - failed to list tracked files (dry-run)"
	@echo "--------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 1 "Failed to list tracked files"'
	@echo "6j. gitx-untrack - failed to untrack files from index"
	@echo "-----------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to untrack files from index" "Git rm --cached failed"'
	@echo "6k. gitx-untrack - failed to create exclude backup"
	@echo "--------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to create exclude backup" "$$HOME/.gitx/repos/demo-repo/repo/info/exclude.bak"'
	@echo "6l. gitx-untrack - failed to update exclude file"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-untrack" "demo-repo" 0 "Failed to update exclude file" "$$HOME/.gitx/repos/demo-repo/repo/info/exclude"'
	@echo "6m. gitx-track - repo not found (actual)"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-track" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6n. gitx-track - repo not found (dry-run)"
	@echo "-----------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-track" "demo-repo" 1 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6o. gitx-commit - repo not found"
	@echo "--------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Repo not found" "$$HOME/.gitx/repos/demo-repo/repo"'
	@echo "6p. gitx-commit - failed to auto-stage tracked changes"
	@echo "------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Failed to auto-stage tracked changes"'
	@echo "6q. gitx-commit - failed while checking staged changes"
	@echo "------------------------------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Failed while checking staged changes"'
	@echo "6r. gitx-commit - commit failed"
	@echo "-------------------------------"
	@fish -c 'source functions/__gitx_present_problem.fish; __gitx_present_problem "gitx-commit" "demo-repo" 0 "Commit failed"'

demo-usage-presenter: setup-fish
	@echo "7. USAGE PRESENTER"
	@echo "7a. gitx usage - with available repos"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx with-repos "demo-repo" "configs-repo"'
	@echo "7b. gitx usage - single repo missing git args"
	@echo "---------------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-git-args "demo-repo"'
	@echo "7c. gitx usage - no repos found"
	@echo "-------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos "$$HOME/.gitx/repos"'
	@echo "7d. gitx usage - repos directory missing"
	@echo "---------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx missing-repos-dir "$$HOME/.gitx/repos"'
	@echo "7e. gitx-init usage"
	@echo "-------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-init" "gitx-init [--dry-run] <repo> [remote-url]"'
	@echo "7f. gitx-track usage"
	@echo "--------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-track" "gitx-track [--dry-run] <repo> <file> [file ...]"'
	@echo "7g. gitx-untrack usage"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-untrack" "gitx-untrack [--dry-run] <repo> <file> [file ...]"'
	@echo "7h. gitx-commit usage"
	@echo "---------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx-commit" "gitx-commit [--dry-run] <repo> [-m|--message <text>]"'

test-presenter-contracts: setup-fish test-passthrough-presenter-contracts test-usage-gitx-presenter-contracts

test-passthrough-presenter-contracts: setup-fish
	@echo "8. PASSTHROUGH PRESENTER CONTRACTS"
	@echo "8a. Missing mode argument"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough' 2>&1 | rg -F "Error: __gitx_present_passthrough requires at least 1 argument" || exit 1
	@echo "8b. Unknown mode"
	@echo "----------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough invalid-mode' 2>&1 | rg -F "Error: __gitx_present_passthrough unknown mode: invalid-mode" || exit 1
	@echo "8c. begin with extra args"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough begin extra' 2>&1 | rg -F "Error: __gitx_present_passthrough begin takes no extra arguments" || exit 1
	@echo "8d. entry-start missing repo"
	@echo "----------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-start' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-start requires exactly 1 argument" || exit 1
	@echo "8e. entry-end missing args"
	@echo "--------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-end' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-end requires exactly 2 arguments" || exit 1
	@echo "8f. entry-end invalid success"
	@echo "-----------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough entry-end 2 demo-repo' 2>&1 | rg -F "Error: __gitx_present_passthrough entry-end success must be 0 or 1" || exit 1
	@echo ""
	@echo "  ✓ All passthrough presenter contract tests passed"

test-usage-gitx-presenter-contracts: setup-fish
	@echo "9. USAGE GITX PRESENTER CONTRACTS"
	@echo "9a. Missing mode argument"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx' 2>&1 | rg -F "Error: __gitx_present_usage_gitx requires at least 1 argument" || exit 1
	@echo "9b. Unknown mode"
	@echo "----------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx bad-mode' 2>&1 | rg -F "Error: __gitx_present_usage_gitx unknown mode: bad-mode" || exit 1
	@echo "9c. with-repos missing repo names"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx with-repos' 2>&1 | rg -F "Error: __gitx_present_usage_gitx with-repos requires at least 1 repo name" || exit 1
	@echo "9d. no-repos missing path"
	@echo "-------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-repos requires exactly 1 path argument" || exit 1
	@echo "9e. no-repos extra arg"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-repos /tmp extra' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-repos requires exactly 1 path argument" || exit 1
	@echo "9f. missing-repos-dir wrong arity"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx missing-repos-dir' 2>&1 | rg -F "Error: __gitx_present_usage_gitx missing-repos-dir requires exactly 1 path argument" || exit 1
	@echo "9g. no-git-args wrong arity"
	@echo "---------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx no-git-args' 2>&1 | rg -F "Error: __gitx_present_usage_gitx no-git-args requires exactly 1 repo name argument" || exit 1
	@echo ""
	@echo "  ✓ All usage gitx presenter contract tests passed"

setup-fish:
	@command -v fish >/dev/null 2>&1 || { echo "Installing fish shell..."; sudo apt-get update -qq && sudo apt-get install -y -qq fish > /dev/null 2>&1; }
