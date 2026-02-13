function gitx --description 'Run git commands against a gitx repo or all of them at once'
    set -l repos_dir "$HOME/.gitx/repos"

    if test (count $argv) -lt 1
        if test -d "$repos_dir"
            set -l names
            for d in "$repos_dir"/*
                if test -d "$d"
                    set names $names (basename "$d")
                end
            end
            if test (count $names) -gt 0
                __gitx_present_usage_gitx with-repos $names >&2
            else
                __gitx_present_usage_gitx no-repos "$repos_dir" >&2
            end
        else
            __gitx_present_usage_gitx missing-repos-dir "$repos_dir" >&2
        end

        return 1
    end

    set -l first $argv[1]
    set -l maybe_repo "$repos_dir/$first/repo"

    # Single-repo mode wins if first argument matches an existing repo.
    if test -d "$maybe_repo"
        if test (count $argv) -lt 2
            __gitx_present_usage_gitx no-git-args "$first" >&2
            return 1
        end

        set -l single_cmd git -C / --git-dir="$maybe_repo" --work-tree=/ $argv[2..-1]
        __gitx_present_passthrough begin
        __gitx_present_passthrough entry-start "$first"
        command $single_cmd
        set -l rc $status

        set -l success 0
        if test $rc -eq 0
            set success 1
        end

        __gitx_present_passthrough entry-end $success "$first"

        return $rc
    end

    # All-repos mode: treat full argv as raw git command.
    set -l repo_names
    set -l repos
    if test -d "$repos_dir"
        for d in "$repos_dir"/*
            if test -d "$d/repo"
                set repo_names $repo_names (basename "$d")
                set repos $repos "$d/repo"
            end
        end
    end

    if test (count $repo_names) -eq 0
        __gitx_present_problem "gitx" "-" 0 "No repos found" "$repos_dir"
        return 1
    end

    set -l any_failure 0
    __gitx_present_passthrough begin

    for i in (seq 1 (count $repo_names))
        set -l repo_name $repo_names[$i]
        set -l repo $repos[$i]

        set -l repo_cmd git -C / --git-dir="$repo" --work-tree=/ $argv
        __gitx_present_passthrough entry-start "$repo_name"
        command $repo_cmd
        set -l rc $status

        set -l success 0
        if test $rc -eq 0
            set success 1
        else
            set any_failure 1
        end

        __gitx_present_passthrough entry-end $success "$repo_name"
    end
    
    if test $any_failure -eq 1
        return 1
    end

    return 0
end
