function gitx-untrack --description 'Untrack files from ~/.gitx bare profile and safely prune auto-unignore entries'
    if test (count $argv) -lt 2
        echo "Usage: gitx-untrack [--dry-run] <profile> <file> [file ...]" >&2
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
        echo "Usage: gitx-untrack [--dry-run] <profile> <file> [file ...]" >&2
        return 1
    end

    set -l profile $args[1]
    set -l repo "$HOME/.gitx/profiles/$profile/repo"
    set -l exclude "$repo/info/exclude"

    if not test -d "$repo"
        echo "gitx-untrack: profile repo not found: $repo" >&2
        return 1
    end

    set -l tracked (command git -C / --git-dir="$repo" --work-tree=/ ls-files)
    or begin
        echo "gitx-untrack: failed to list tracked files" >&2
        return 1
    end

    set -l to_untrack
    set -l removed_abs

    for raw in $args[2..-1]
        set -l expanded $raw
        if string match -q '~*' -- $expanded
            set expanded (string replace -r '^~' "$HOME" -- $expanded)
        end

        set -l abs (path resolve -- "$expanded")
        set -l norm (string replace -a '\\' '/' -- "$abs")
        set -l idx (string trim -l -c '/' -- "$norm")

        if contains -- "$idx" $tracked
            if not contains -- "$idx" $to_untrack
                set to_untrack $to_untrack "$idx"
                set removed_abs $removed_abs "$norm"
            end
        else
            echo "gitx-untrack: not tracked, skipping: $raw" >&2
        end
    end

    if test (count $to_untrack) -eq 0
        echo "gitx-untrack: no tracked files matched" >&2
        return 1
    end

    set -l rm_cmd git -C / --git-dir="$repo" --work-tree=/ rm --cached -- $to_untrack
    set -l run_cmds
    set -l run_targets
    for p in $to_untrack
        set run_targets $run_targets "/$p"
    end

    if test $dry_run -eq 0
        command $rm_cmd
        or begin
            echo "gitx-untrack: git rm --cached failed" >&2
            return 1
        end
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $rm_cmd))
    end

    if not test -f "$exclude"
        if test $dry_run -eq 1
            set -l dry_targets
            for p in $to_untrack
                set dry_targets $dry_targets "/$p"
            end
            set -l dry_cmds (string join -- ' ' (string escape -- $rm_cmd))
            echo "Dry Run Plan: gitx-untrack $profile"
            echo
            __gitx_print_section "Would untrack paths" $dry_targets
            __gitx_print_section "Would remove exclude entries" "(exclude file missing: $exclude)"
            __gitx_print_section "Would run commands" $dry_cmds
            echo "Summary: untrack_paths="(count $to_untrack)", exclude_entries_removed=0, commands="(count $dry_cmds)
        else
            echo "Untrack Result: gitx-untrack $profile"
            echo
            __gitx_print_section "Untracked paths" $run_targets
            __gitx_print_section "Exclude updates" "(exclude file missing: $exclude)"
            __gitx_print_section "Commands run" $run_cmds
            echo "Summary: untrack_paths="(count $to_untrack)", exclude_entries_removed=0, commands="(count $run_cmds)
        end
        return 0
    end

    # Compute remaining tracked files after untracking targets.
    set -l remaining $tracked
    for p in $to_untrack
        set -l next
        for t in $remaining
            if test "$t" != "$p"
                set next $next "$t"
            end
        end
        set remaining $next
    end

    # Build required unignore entries for remaining tracked files.
    set -l required
    for t in $remaining
        set -l trimmed (string trim -l -c '/' -- "$t")
        if test -z "$trimmed"
            continue
        end

        set -l parts (string split '/' -- "$trimmed")
        set -l prefix ""

        for i in (seq 1 (math (count $parts) - 1))
            if test -z "$prefix"
                set prefix $parts[$i]
            else
                set prefix "$prefix/$parts[$i]"
            end

            set -l entry "!/$prefix/"
            if not contains -- "$entry" $required
                set required $required "$entry"
            end
        end

        set -l file_entry "!/$trimmed"
        if not contains -- "$file_entry" $required
            set required $required "$file_entry"
        end
    end

    # Build candidate entries from files being untracked.
    set -l candidates
    for abs in $removed_abs
        set -l trimmed (string trim -l -c '/' -- (string replace -a '\\' '/' -- "$abs"))
        if test -z "$trimmed"
            continue
        end

        set -l parts (string split '/' -- "$trimmed")
        set -l prefix ""

        for i in (seq 1 (math (count $parts) - 1))
            if test -z "$prefix"
                set prefix $parts[$i]
            else
                set prefix "$prefix/$parts[$i]"
            end

            set -l entry "!/$prefix/"
            if not contains -- "$entry" $candidates
                set candidates $candidates "$entry"
            end
        end

        set -l file_entry "!/$trimmed"
        if not contains -- "$file_entry" $candidates
            set candidates $candidates "$file_entry"
        end
    end

    # Determine which candidate entries can be safely removed.
    set -l remove_entries
    while read -l line
        set -l trimmed (string trim -- "$line")
        if contains -- "$trimmed" $candidates
            if not contains -- "$trimmed" $required
                if not contains -- "$trimmed" $remove_entries
                    set remove_entries $remove_entries "$trimmed"
                end
            end
        end
    end < "$exclude"

    if test $dry_run -eq 1
        set -l dry_targets
        for p in $to_untrack
            set dry_targets $dry_targets "/$p"
        end

        set -l dry_cmds
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $rm_cmd))

        if test (count $remove_entries) -gt 0
            set -l backup "$exclude.bak"
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- cp "$exclude" "$backup"))
            set dry_cmds $dry_cmds "rewrite $exclude (without removed entries)"
        end

        echo "Dry Run Plan: gitx-untrack $profile"
        echo
        __gitx_print_section "Would untrack paths" $dry_targets
        __gitx_print_section "Would remove exclude entries" $remove_entries
        __gitx_print_section "Would run commands" $dry_cmds
        echo "Summary: untrack_paths="(count $to_untrack)", exclude_entries_removed="(count $remove_entries)", commands="(count $dry_cmds)
        return 0
    end

    if test (count $remove_entries) -eq 0
        echo "Untrack Result: gitx-untrack $profile"
        echo
        __gitx_print_section "Untracked paths" $run_targets
        __gitx_print_section "Exclude entries removed" "(none)"
        __gitx_print_section "Commands run" $run_cmds
        echo "Summary: untrack_paths="(count $to_untrack)", exclude_entries_removed=0, commands="(count $run_cmds)
        return 0
    end

    set -l tmp (mktemp)
    while read -l line
        set -l trimmed (string trim -- "$line")
        if contains -- "$trimmed" $remove_entries
            continue
        end
        echo "$line" >> "$tmp"
    end < "$exclude"

    cp "$exclude" "$exclude.bak"
    or begin
        rm -f "$tmp"
        echo "gitx-untrack: failed to create backup: $exclude.bak" >&2
        return 1
    end
    set run_cmds $run_cmds (string join -- ' ' (string escape -- cp "$exclude" "$exclude.bak"))

    mv "$tmp" "$exclude"
    or begin
        rm -f "$tmp"
        echo "gitx-untrack: failed to update exclude file" >&2
        return 1
    end
    set run_cmds $run_cmds "rewrite $exclude (without removed entries)"

    echo "Untrack Result: gitx-untrack $profile"
    echo
    __gitx_print_section "Untracked paths" $run_targets
    __gitx_print_section "Exclude entries removed" $remove_entries
    __gitx_print_section "Commands run" $run_cmds
    echo "Summary: untrack_paths="(count $to_untrack)", exclude_entries_removed="(count $remove_entries)", commands="(count $run_cmds)
    echo
    __gitx_print_section "Next step" "gitx $profile commit -m \"untrack files\""
end
