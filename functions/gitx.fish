function gitx --description 'Run git for one repo or all ~/.gitx/repos when repo is omitted'
    set -l repos_dir "$HOME/.gitx/repos"

    if test (count $argv) -lt 1
        echo "Usage:" >&2
        echo "  gitx <repo> <git args...>     # single repo" >&2
        echo "  gitx <git args...>               # all repos" >&2

        if test -d "$repos_dir"
            set -l names
            for d in "$repos_dir"/*
                if test -d "$d"
                    set names $names (basename "$d")
                end
            end
            if test (count $names) -gt 0
                echo "Available repos:" >&2
                for name in $names
                    echo "  $name" >&2
                end
            else
                echo "No repos found in $repos_dir" >&2
            end
        else
            echo "Repos directory not found: $repos_dir" >&2
        end

        return 1
    end

    set -l first $argv[1]
    set -l maybe_repo "$repos_dir/$first/repo"

    # Single-repo mode wins if first argument matches an existing repo.
    if test -d "$maybe_repo"
        if test (count $argv) -lt 2
            echo "Usage: gitx <repo> <git args...>" >&2
            return 1
        end

        set -l single_cmd git -C / --git-dir="$maybe_repo" --work-tree=/ $argv[2..-1]
        set -l output (command $single_cmd 2>&1 | string collect)
        set -l rc $status

        set -l out_lines
        if test -n "$output"
            for line in (string split \n -- "$output")
                if test -n "$line"
                    set out_lines $out_lines "$line"
                end
            end
        end

        if test $rc -eq 0
            __gitx_print_mode "Success"
        else
            __gitx_print_mode "Failed"
        end
        
        __gitx_print_section "Repo" "$first"
        
        # Show output if not empty
        if test -n "$output"
            echo "$output"
            echo
        end
        
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
        echo "gitx: no repos found in $repos_dir" >&2
        return 1
    end

    set -l subcmd $argv[1]

    set -l ok_count 0
    set -l noop_count 0
    set -l fail_count 0
    set -l failed_repos

    for i in (seq 1 (count $repo_names))
        set -l repo_name $repo_names[$i]
        set -l repo $repos[$i]

        set -l repo_cmd git -C / --git-dir="$repo" --work-tree=/ $argv
        set -l output (command $repo_cmd 2>&1 | string collect)
        set -l rc $status

        set -l out_lines
        if test -n "$output"
            for line in (string split \n -- "$output")
                if test -n "$line"
                    set out_lines $out_lines "$line"
                end
            end
        end

        set -l lowered (string lower -- "$output")
        set -l is_noop 0

        if test $rc -ne 0
            if test "$subcmd" = "commit"
                if string match -q '*nothing to commit*' -- "$lowered"
                    set is_noop 1
                else if string match -q '*nothing added to commit*' -- "$lowered"
                    set is_noop 1
                else if string match -q '*no changes added to commit*' -- "$lowered"
                    set is_noop 1
                end
            end
        end

        set -l repo_status
        if test $rc -eq 0
            set ok_count (math $ok_count + 1)
            set repo_status "ok"
        else if test $is_noop -eq 1
            set noop_count (math $noop_count + 1)
            set repo_status "noop"
        else
            set fail_count (math $fail_count + 1)
            set failed_repos $failed_repos "$repo_name"
            set repo_status "failed"
            set repo_status $repo_status "Exit code: $rc"
        end

        # Print repo result inline
        set_color brblack
        printf "  %s: " "$repo_name"
        set_color normal
        
        if test $rc -eq 0
            set_color green
            echo "✓"
            set_color normal
        else if test $is_noop -eq 1
            echo "(no changes)"
        else
            set_color red
            printf "✗ (exit %d)\n" $rc
            set_color normal
        end
    end

    echo
    __gitx_print_summary \
        "Total repos" (count $repo_names) \
        "Success" "$ok_count" \
        "No changes" "$noop_count" \
        "Failed" "$fail_count"
    
    if test $fail_count -gt 0
        return 1
    end

    return 0
end
