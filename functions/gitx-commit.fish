function gitx-commit --description 'Commit staged changes for ~/.gitx profile with optional message and dry-run'
    argparse 'n/dry-run' 'm/message=' -- $argv
    or begin
        echo "Usage: gitx-commit [--dry-run] <profile> [-m|--message <text>]" >&2
        return 1
    end

    if test (count $argv) -ne 1
        echo "Usage: gitx-commit [--dry-run] <profile> [-m|--message <text>]" >&2
        return 1
    end

    set -l profile $argv[1]
    set -l repo "$HOME/.gitx/profiles/$profile/repo"

    if not test -d "$repo"
        echo "gitx-commit: profile repo not found: $repo" >&2
        return 1
    end

    set -l message
    if set -q _flag_message
        set message "$_flag_message"
    else
        set message (date "+%A, %b %e %I:%M%p UTC%z" | string replace -r '  +' ' ')
    end

    set -l unstaged_cmd git --git-dir="$repo" --work-tree=/ diff --name-only
    set -l auto_add_cmd git --git-dir="$repo" --work-tree=/ add -u
    set -l check_cmd git --git-dir="$repo" --work-tree=/ diff --cached --quiet --exit-code
    set -l staged_cmd git --git-dir="$repo" --work-tree=/ diff --cached --name-only
    set -l commit_cmd git --git-dir="$repo" --work-tree=/ commit -m "$message"

    set -l unstaged_files (command $unstaged_cmd)
    set -l staged_files

    if test -n "$_flag_dry_run"
        set staged_files (command $staged_cmd)
        set -l dry_auto_files
        for f in $unstaged_files
            if not contains -- "$f" $staged_files
                set staged_files $staged_files "$f"
            end
            set dry_auto_files $dry_auto_files "/$f"
        end

        set -l has_staged_status 0
        if test (count $staged_files) -gt 0
            set has_staged_status 1
        end

        set -l dry_files
        for f in $staged_files
            set dry_files $dry_files "/$f"
        end

        set -l dry_cmds
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $auto_add_cmd))
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $check_cmd))
        if test $has_staged_status -eq 1
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $commit_cmd))
        end

        set -l dry_message "message: $message"
        if test $has_staged_status -eq 0
            set dry_message $dry_message "note: no staged changes; commit would not run"
        end

        echo "Dry Run Plan: gitx-commit $profile"
        echo
        __gitx_print_section "Would auto-stage modified tracked files" $dry_auto_files
        __gitx_print_section "Would include staged files" $dry_files
        __gitx_print_section "Commit message" $dry_message
        __gitx_print_section "Would run commands" $dry_cmds

        if test $has_staged_status -eq 0
            echo "Summary: staged_files=0, commands="(count $dry_cmds)", commit_would_run=no"
            return 1
        end

        echo "Summary: staged_files="(count $staged_files)", commands="(count $dry_cmds)", commit_would_run=yes"
        return 0
    end

    command $auto_add_cmd
    or begin
        echo "gitx-commit: failed to auto-stage tracked changes" >&2
        return 1
    end

    command $check_cmd
    set -l has_staged_status $status
    if test $has_staged_status -ne 0 -a $has_staged_status -ne 1
        echo "gitx-commit: failed while checking staged changes" >&2
        return 1
    end

    if test $has_staged_status -eq 1
        set staged_files (command $staged_cmd)
    end

    if test $has_staged_status -eq 0
        echo "Commit Result: gitx-commit $profile"
        echo
        set -l run_auto_files
        for f in $unstaged_files
            set run_auto_files $run_auto_files "/$f"
        end
        __gitx_print_section "Auto-staged modified tracked files" $run_auto_files
        __gitx_print_section "Staged files" "(none)"
        __gitx_print_section "Commit message" "message: $message" "note: nothing staged; commit not executed"
        __gitx_print_section "Commands run" \
            (string join -- ' ' (string escape -- $auto_add_cmd)) \
            (string join -- ' ' (string escape -- $check_cmd))
        echo "Summary: auto_staged_candidates="(count $unstaged_files)", staged_files=0, commands=2, commit_executed=no"
        return 1
    end

    set -l run_files
    for f in $staged_files
        set run_files $run_files "/$f"
    end
    set -l run_auto_files
    for f in $unstaged_files
        set run_auto_files $run_auto_files "/$f"
    end

    command $commit_cmd
    or begin
        echo "gitx-commit: commit failed" >&2
        return 1
    end

    echo "Commit Result: gitx-commit $profile"
    echo
    __gitx_print_section "Auto-staged modified tracked files" $run_auto_files
    __gitx_print_section "Staged files" $run_files
    __gitx_print_section "Commit message" "message: $message"
    __gitx_print_section "Commands run" \
        (string join -- ' ' (string escape -- $auto_add_cmd)) \
        (string join -- ' ' (string escape -- $check_cmd)) \
        (string join -- ' ' (string escape -- $commit_cmd))
    echo "Summary: auto_staged_candidates="(count $unstaged_files)", staged_files="(count $staged_files)", commands=3, commit_executed=yes"
end
