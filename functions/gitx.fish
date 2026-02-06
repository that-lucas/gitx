function gitx --description 'Run git for one profile or all ~/.gitx/profiles when profile is omitted'
    set -l profiles_dir "$HOME/.gitx/profiles"

    if test (count $argv) -lt 1
        echo "Usage:" >&2
        echo "  gitx <profile> <git args...>     # single profile" >&2
        echo "  gitx <git args...>               # all profiles" >&2

        if test -d "$profiles_dir"
            set -l names
            for d in "$profiles_dir"/*
                if test -d "$d"
                    set names $names (basename "$d")
                end
            end
            if test (count $names) -gt 0
                echo "Available profiles:" >&2
                for name in $names
                    echo "  $name" >&2
                end
            else
                echo "No profiles found in $profiles_dir" >&2
            end
        else
            echo "Profiles directory not found: $profiles_dir" >&2
        end

        return 1
    end

    set -l first $argv[1]
    set -l maybe_repo "$profiles_dir/$first/repo"

    # Single-profile mode wins if first argument matches an existing profile.
    if test -d "$maybe_repo"
        if test (count $argv) -lt 2
            echo "Usage: gitx <profile> <git args...>" >&2
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

        echo "Gitx Result: profile $first"
        echo
        __gitx_print_section "Command" (string join -- ' ' (string escape -- $single_cmd))
        __gitx_print_section "Output" $out_lines
        __gitx_print_section "Status" "exit_code=$rc"
        echo "Summary: profiles=1, ok="(test $rc -eq 0; and echo 1; or echo 0)", noop=0, failed="(test $rc -eq 0; and echo 0; or echo 1)
        return $rc
    end

    # All-profiles mode: treat full argv as raw git command.
    set -l profiles
    set -l repos
    if test -d "$profiles_dir"
        for d in "$profiles_dir"/*
            if test -d "$d/repo"
                set profiles $profiles (basename "$d")
                set repos $repos "$d/repo"
            end
        end
    end

    if test (count $profiles) -eq 0
        echo "gitx: no profiles with repo found in $profiles_dir" >&2
        return 1
    end

    set -l subcmd $argv[1]

    set -l ok_count 0
    set -l noop_count 0
    set -l fail_count 0
    set -l failed_profiles

    for i in (seq 1 (count $profiles))
        set -l profile $profiles[$i]
        set -l repo $repos[$i]

        set -l profile_cmd git -C / --git-dir="$repo" --work-tree=/ $argv
        echo "Gitx Result: profile $profile"
        echo

        set -l output (command $profile_cmd 2>&1 | string collect)
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

        set -l profile_status
        if test $rc -eq 0
            set ok_count (math $ok_count + 1)
            set profile_status "status=ok"
        else if test $is_noop -eq 1
            set noop_count (math $noop_count + 1)
            set profile_status "status=noop"
        else
            set fail_count (math $fail_count + 1)
            set failed_profiles $failed_profiles "$profile"
            set profile_status "status=failed"
            set profile_status $profile_status "exit_code=$rc"
        end

        __gitx_print_section "Command" (string join -- ' ' (string escape -- $profile_cmd))
        __gitx_print_section "Output" $out_lines
        __gitx_print_section "Status" $profile_status
        echo
    end

    echo "Summary: profiles="(count $profiles)", ok=$ok_count, noop=$noop_count, failed=$fail_count"
    if test $fail_count -gt 0
        echo "Failed profiles: "(string join ', ' $failed_profiles)
        return 1
    end

    return 0
end
