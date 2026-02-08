.PHONY: test-presenters test-all-presenters test-init-presenter test-track-presenter test-untrack-presenter test-commit-presenter test-passthrough-presenter test-problem-presenter test-usage-presenter setup-fish

test-presenters: test-all-presenters

test-all-presenters: setup-fish test-init-presenter test-track-presenter test-untrack-presenter test-commit-presenter test-passthrough-presenter test-problem-presenter test-usage-presenter

test-init-presenter: setup-fish
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

test-track-presenter: setup-fish
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

test-untrack-presenter: setup-fish
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

test-commit-presenter: setup-fish
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

test-passthrough-presenter: setup-fish
	@echo "5. PASSTHROUGH PRESENTER"
	@echo "5a. Passthrough - Success with output"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 1 demo-repo 3 "A  tmp/test1.txt" "A  tmp/test2.txt" "M  tmp/test3.txt"'
	@echo "5b. Passthrough - Failure with error"
	@echo "------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 0 demo-repo 1 "git: '"'"'invalid-command'"'"' is not a git command. See '"'"'git --help'"'"'."'
	@echo "5c. Passthrough - Success with no output"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 1 demo-repo 0'
	@echo "5d. Passthrough - Multiple repos (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 2 1 demo-repo 1 "A  tmp/test1.txt" 1 configs-repo 2 "M  .gitconfig" "M  .config/fish/config.fish"'
	@echo "5e. Passthrough - Multiple repos (mixed results)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 2 1 demo-repo 1 "A  tmp/test1.txt" 0 dotfiles 1 "fatal: unable to access '"'"'https://github.com/user/dotfiles.git/'"'"': Could not resolve host: github.com"'

test-problem-presenter: setup-fish
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

test-usage-presenter: setup-fish
	@echo "7. USAGE PRESENTER"
	@echo "7a. gitx usage - with available repos"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_usage_gitx.fish; __gitx_present_usage_gitx "demo-repo" "configs-repo"'
	@echo "7b. gitx usage - missing repo command args"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx" "gitx <repo> <git args...>"'
	@echo "7c. gitx usage - no repos found"
	@echo "-------------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx" "gitx <repo> <git args...> # single repo" "gitx        <git args...> # all repos" "" "No repos found in $$HOME/.gitx/repos"'
	@echo "7d. gitx usage - repos directory missing"
	@echo "---------------------------------------"
	@fish -c 'source functions/__gitx_present_usage.fish; __gitx_present_usage "gitx" "gitx <repo> <git args...> # single repo" "gitx        <git args...> # all repos" "" "Repos directory not found: $$HOME/.gitx/repos"'
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

setup-fish:
	@command -v fish >/dev/null 2>&1 || { echo "Installing fish shell..."; sudo apt-get update -qq && sudo apt-get install -y -qq fish > /dev/null 2>&1; }
