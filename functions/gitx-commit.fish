function gitx-commit --description 'Commit staged changes for ~/.gitx repo with optional message and dry-run'
    argparse 'n/dry-run' 'm/message=' -- $argv
    or begin
        __gitx_present_usage "gitx-commit" "gitx-commit [--dry-run] <repo> [-m|--message <text>]" >&2
        return 1
    end

    if test (count $argv) -ne 1
        __gitx_present_usage "gitx-commit" "gitx-commit [--dry-run] <repo> [-m|--message <text>]" >&2
        return 1
    end

    set -l repo_name $argv[1]
    set -l repo "$HOME/.gitx/repos/$repo_name/repo"

    if not test -d "$repo"
        __gitx_present_problem "gitx-commit" "$repo_name" 0 "Repo not found" "$repo"
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

        set -l dry_message "Message: $message"
        if test $has_staged_status -eq 0
            set dry_message $dry_message "Note: no staged changes; commit would not run"
        end

        if test $has_staged_status -eq 0
            __gitx_present_commit 1 "$repo_name" 0 "$message"
            return 0
        end

        __gitx_present_commit 1 "$repo_name" (count $staged_files) "$message" $dry_files
        return 0
    end

    command $auto_add_cmd >/dev/null 2>/dev/null
    or begin
        __gitx_present_problem "gitx-commit" "$repo_name" 0 "Failed to auto-stage tracked changes"
        return 1
    end

    command $check_cmd >/dev/null 2>/dev/null
    set -l has_staged_status $status
    if test $has_staged_status -ne 0 -a $has_staged_status -ne 1
        __gitx_present_problem "gitx-commit" "$repo_name" 0 "Failed while checking staged changes"
        return 1
    end

    if test $has_staged_status -eq 1
        set staged_files (command $staged_cmd)
    end

    if test $has_staged_status -eq 0
        __gitx_present_commit 0 "$repo_name" 0 "$message"
        return 0
    end

    set -l run_files
    for f in $staged_files
        set run_files $run_files "/$f"
    end
    set -l run_auto_files
    for f in $unstaged_files
        set run_auto_files $run_auto_files "/$f"
    end

    command $commit_cmd >/dev/null 2>/dev/null
    or begin
        __gitx_present_problem "gitx-commit" "$repo_name" 0 "Commit failed"
        return 1
    end

    __gitx_present_commit 0 "$repo_name" (count $staged_files) "$message" $run_files
end
