function gitx-track --description 'Unignore and stage files into ~/.gitx/repos/<repo>/repo'
    if test (count $argv) -lt 2
        echo "Usage: gitx-track [--dry-run] <repo> <file> [file ...]" >&2
        return 1
    end

    set -l dry_run 0
    set -l args
    for a in $argv
        if test "$a" = "--dry-run"
            set dry_run 1
        else
            set args $args $a
        end
    end

    if test (count $args) -lt 2
        echo "Usage: gitx-track [--dry-run] <repo> <file> [file ...]" >&2
        return 1
    end

    set -l repo_name $args[1]
    set -l repo "$HOME/.gitx/repos/$repo_name/repo"
    set -l exclude "$repo/info/exclude"

    if not test -d "$repo"
        echo "gitx-track: repo not found: $repo" >&2
        return 1
    end

    set -l dry_targets
    set -l dry_exclude
    set -l dry_track
    set -l dry_cmds
    set -l run_targets
    set -l run_staged
    set -l run_tracked_no_diff
    set -l run_skipped
    set -l run_exclude
    set -l run_cmds

    if not test -f "$exclude"
        set -l mkinfo_cmd mkdir -p "$repo/info"
        if test $dry_run -eq 1
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $mkinfo_cmd))
            set dry_exclude $dry_exclude "/*"
        else
            command $mkinfo_cmd
            printf "/*\n" > "$exclude"
        end
    end

    set -l tracked_count 0
    set -l staged_count 0

    for raw in $args[2..-1]
        set -l expanded $raw
        if string match -q '~*' -- $expanded
            set expanded (string replace -r '^~' "$HOME" -- $expanded)
        end

        if not test -e "$expanded"
            set run_skipped $run_skipped "path not found: $raw"
            continue
        end

        if test -d "$expanded"
            set run_skipped $run_skipped "directory not allowed (pass files explicitly): $raw"
            continue
        end

        set -l abs (path resolve -- "$expanded")
        set -l norm (string replace -a '\\' '/' -- "$abs")
        set -l root_relative (string trim -l -c '/' -- "$norm")

        if test -z "$root_relative"
            set run_skipped $run_skipped "cannot track root path: $raw"
            continue
        end

        set -l parts (string split '/' -- "$root_relative")
        set -l prefix ""

        for i in (seq 1 (math (count $parts) - 1))
            if test -z "$prefix"
                set prefix $parts[$i]
            else
                set prefix "$prefix/$parts[$i]"
            end

            set -l entry "!/$prefix/"
            if not grep -Fxq -- "$entry" "$exclude" 2>/dev/null
                if test $dry_run -eq 1
                    if not contains -- "$entry" $dry_exclude
                        set dry_exclude $dry_exclude "$entry"
                    end
                else
                    echo "$entry" >> "$exclude"
                    set run_exclude $run_exclude "$entry"
                end
            end
        end

        set -l file_entry "!/$root_relative"
        if not grep -Fxq -- "$file_entry" "$exclude" 2>/dev/null
            if test $dry_run -eq 1
                if not contains -- "$file_entry" $dry_exclude
                    set dry_exclude $dry_exclude "$file_entry"
                end
            else
                echo "$file_entry" >> "$exclude"
                set run_exclude $run_exclude "$file_entry"
            end
        end

        set -l add_cmd git -C / --git-dir="$repo" --work-tree=/ add -f -- "$root_relative"
        if test $dry_run -eq 1
            set dry_targets $dry_targets "$norm"
            set dry_track $dry_track "/$root_relative"
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $add_cmd))
            set tracked_count (math $tracked_count + 1)
            continue
        end

        set run_targets $run_targets "$norm"

        command $add_cmd >/dev/null 2>/dev/null
        or begin
            set run_skipped $run_skipped "git add failed: $norm"
            continue
        end
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $add_cmd))

        # Verify index entry exists. For files inside nested git repos, add -f may no-op;
        # fallback to plumbing commands that force index entry creation.
        set -l verify_cmd git -C / --git-dir="$repo" --work-tree=/ ls-files --error-unmatch -- "$root_relative"
        command $verify_cmd >/dev/null 2>/dev/null
        if test $status -ne 0
            set -l mode 100644
            if test -x "$norm"
                set mode 100755
            end

            set -l hash_cmd git -C / --git-dir="$repo" hash-object -w -- "$norm"
            set -l blob_hash (command $hash_cmd 2>/dev/null)
            if test $status -ne 0 -o -z "$blob_hash"
                set run_skipped $run_skipped "fallback hash-object failed: $norm"
                continue
            end
            set run_cmds $run_cmds (string join -- ' ' (string escape -- $hash_cmd))

            set -l update_cmd git -C / --git-dir="$repo" --work-tree=/ update-index --add --cacheinfo "$mode" "$blob_hash" "$root_relative"
            command $update_cmd >/dev/null 2>/dev/null
            or begin
                set run_skipped $run_skipped "fallback update-index failed: $norm"
                continue
            end
            set run_cmds $run_cmds (string join -- ' ' (string escape -- $update_cmd))

            command $verify_cmd >/dev/null 2>/dev/null
            if test $status -ne 0
                set run_skipped $run_skipped "file not added to index: $norm"
                continue
            end
        end

        set tracked_count (math $tracked_count + 1)

        set -l staged_cmd git -C / --git-dir="$repo" --work-tree=/ diff --cached --name-only -- "$root_relative"
        set -l staged_now (command $staged_cmd)
        if test (count $staged_now) -gt 0
            set staged_count (math $staged_count + 1)
            set run_staged $run_staged "$norm"
        else
            set run_tracked_no_diff $run_tracked_no_diff "$norm"
        end
    end

    if test $dry_run -eq 1
        __gitx_print_mode "Dry-run mode"
        __gitx_print_section "Resolved targets" $dry_targets
        __gitx_print_section "Would append to exclude" $dry_exclude
        __gitx_print_section "Would track paths" $dry_track
        __gitx_print_section "Would run" $dry_cmds
        __gitx_print_summary \
            "Repo" "$repo_name" \
            "Commands" (count $dry_cmds) \
            "  Targets" (count $dry_targets) \
            "  Exclude entries" (count $dry_exclude) \
            "  Track paths" (count $dry_track)
        if test $tracked_count -eq 0
            return 1
        end
        return 0
    end

    if test $tracked_count -eq 0
        return 1
    end

    __gitx_print_mode "Track result"
    __gitx_print_section "Tracked paths" $run_targets
    __gitx_print_section "Staged paths" $run_staged
    __gitx_print_section "Tracked with no staged diff" $run_tracked_no_diff
    __gitx_print_section "Skipped paths" $run_skipped
    __gitx_print_section "Exclude entries added" $run_exclude
    __gitx_print_section "Ran" $run_cmds
    __gitx_print_summary \
        "Repo" "$repo_name" \
        "Commands" (count $run_cmds) \
        "  Tracked" "$tracked_count" \
        "  Staged" "$staged_count" \
        "  Skipped" (count $run_skipped) \
        "  Exclude entries added" (count $run_exclude)
    __gitx_print_section "Next step" "gitx-commit $repo_name"
end
