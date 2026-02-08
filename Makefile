.PHONY: test-presenters test-all-presenters test-init-presenter test-track-presenter test-untrack-presenter test-commit-presenter test-passthrough-presenter setup-fish

test-presenters: test-all-presenters

test-all-presenters: setup-fish test-init-presenter test-track-presenter test-untrack-presenter test-commit-presenter test-passthrough-presenter

test-init-presenter: setup-fish
	@echo "1. INIT PRESENTER"
	@echo ""
	@echo "1a. Init - Dry-run mode"
	@echo "-----------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 1 /home/user/.gitx/repos/demo-repo/repo "" demo-repo'
	@echo ""
	@echo "1b. Init - Actual mode"
	@echo "----------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 0 /home/user/.gitx/repos/demo-repo/repo "" demo-repo'
	@echo ""
	@echo "1c. Init - Dry-run mode (with remote)"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 1 /home/user/.gitx/repos/demo-repo/repo "git@github.com:user/configs.git" demo-repo'
	@echo ""
	@echo "1d. Init - Actual mode (with remote)"
	@echo "------------------------------------"
	@fish -c 'source functions/__gitx_present_init.fish; __gitx_present_init 0 /home/user/.gitx/repos/demo-repo/repo "git@github.com:user/configs.git" demo-repo'
	@echo ""

test-track-presenter: setup-fish
	@echo "2. TRACK PRESENTER"
	@echo ""
	@echo "2a. Track - Dry-run with 3 files"
	@echo "--------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 1 demo-repo 3 /tmp/test1.txt /tmp/test2.txt /tmp/test3.txt'
	@echo ""
	@echo "2b. Track - Actual with 3 files (success)"
	@echo "-----------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 0 demo-repo 3 /tmp/test1.txt /tmp/test2.txt /tmp/test3.txt'
	@echo ""
	@echo "2c. Track - Dry-run with 0 files (failure case)"
	@echo "-----------------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 1 demo-repo 0'
	@echo ""
	@echo "2d. Track - Actual with 0 files (failure case)"
	@echo "----------------------------------------------"
	@fish -c 'source functions/__gitx_present_track.fish; __gitx_present_track 0 demo-repo 0'
	@echo ""

test-untrack-presenter: setup-fish
	@echo "3. UNTRACK PRESENTER"
	@echo ""
	@echo "3a. Untrack - Dry-run with 2 files"
	@echo "----------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 1 demo-repo 2 /tmp/utest1.txt /tmp/utest2.txt'
	@echo ""
	@echo "3b. Untrack - Actual with 2 files"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 0 demo-repo 2 /tmp/utest1.txt /tmp/utest2.txt'
	@echo ""
	@echo "3c. Untrack - Dry-run with 0 files (failure case)"
	@echo "-------------------------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 1 demo-repo 0'
	@echo ""
	@echo "3d. Untrack - Actual with 0 files (failure case)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_untrack.fish; __gitx_present_untrack 0 demo-repo 0'
	@echo ""

test-commit-presenter: setup-fish
	@echo "4. COMMIT PRESENTER"
	@echo ""
	@echo "4a. Commit - Dry-run with 2 files"
	@echo "---------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 1 demo-repo 2 "Add test files" /tmp/file1.txt /tmp/file2.txt'
	@echo ""
	@echo "4b. Commit - Actual with 2 files (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 0 demo-repo 2 "Update configuration" /tmp/config.txt /tmp/settings.txt'
	@echo ""
	@echo "4c. Commit - Dry-run with 0 files (noop)"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 1 demo-repo 0 "Nothing to commit"'
	@echo ""
	@echo "4d. Commit - Actual with 0 files (noop)"
	@echo "---------------------------------------"
	@fish -c 'source functions/__gitx_present_commit.fish; __gitx_present_commit 0 demo-repo 0 "Nothing to commit"'
	@echo ""

test-passthrough-presenter: setup-fish
	@echo "5. PASSTHROUGH PRESENTER"
	@echo ""
	@echo "5a. Passthrough - Success with output"
	@echo "-------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 1 demo-repo 3 "A  tmp/test1.txt" "A  tmp/test2.txt" "M  tmp/test3.txt"'
	@echo ""
	@echo "5b. Passthrough - Failure with error"
	@echo "------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 0 demo-repo 1 "git: '"'"'invalid-command'"'"' is not a git command. See '"'"'git --help'"'"'."'
	@echo ""
	@echo "5c. Passthrough - Success with no output"
	@echo "----------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 1 1 demo-repo 0'
	@echo ""
	@echo "5d. Passthrough - Multiple repos (success)"
	@echo "------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 2 1 demo-repo 1 "A  tmp/test1.txt" 1 configs-repo 2 "M  .gitconfig" "M  .config/fish/config.fish"'
	@echo ""
	@echo "5e. Passthrough - Multiple repos (mixed results)"
	@echo "------------------------------------------------"
	@fish -c 'source functions/__gitx_present_passthrough.fish; __gitx_present_passthrough 2 1 demo-repo 1 "A  tmp/test1.txt" 0 dotfiles 1 "fatal: unable to access '"'"'https://github.com/user/dotfiles.git/'"'"': Could not resolve host: github.com"'
	@echo ""

setup-fish:
	@command -v fish >/dev/null 2>&1 || { echo "Installing fish shell..."; sudo apt-get update -qq && sudo apt-get install -y -qq fish > /dev/null 2>&1; }
