function gitx-untrack --description 'Stop tracking files from a gitx repo'
    if test (count $argv) -lt 2
        __gitx_present_usage "gitx-untrack" "gitx-untrack [--dry-run] <repo> <file> [file ...]" >&2
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
        __gitx_present_usage "gitx-untrack" "gitx-untrack [--dry-run] <repo> <file> [file ...]" >&2
        return 1
    end

    set -l repo_name $args[1]
    set -l repo "$HOME/.gitx/repos/$repo_name/repo"
    set -l exclude "$repo/info/exclude"

    if not test -d "$repo"
        __gitx_present_problem "gitx-untrack" "$repo_name" "$dry_run" "Repo not found" "$repo"
        return 1
    end

    set -l tracked (command git -C / --git-dir="$repo" --work-tree=/ ls-files)
    or begin
        __gitx_present_problem "gitx-untrack" "$repo_name" "$dry_run" "Failed to list tracked files"
        return 1
    end

    set -l to_untrack
    set -l removed_abs
    set -l skipped_not_tracked

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
            set skipped_not_tracked $skipped_not_tracked "Not tracked, skipping: $raw"
        end
    end

    if test (count $to_untrack) -eq 0
        set -l present_args $dry_run "$repo_name" 0 --reason "No tracked files matched"
        for warning in $skipped_not_tracked
            set present_args $present_args --warning "$warning"
        end
        __gitx_present_untrack $present_args
        return 1
    end

    set -l rm_cmd git -C / --git-dir="$repo" --work-tree=/ rm --cached -- $to_untrack
    set -l run_cmds
    set -l run_targets
    for p in $to_untrack
        set run_targets $run_targets "/$p"
    end

    if test $dry_run -eq 0
        command $rm_cmd >/dev/null 2>/dev/null
        or begin
            __gitx_present_problem "gitx-untrack" "$repo_name" 0 "Failed to untrack files from index" "Git rm --cached failed"
            return 1
        end
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $rm_cmd))
    end

    if not test -f "$exclude"
        # Exclude file missing - just call presenter and return
        set -l present_args $dry_run "$repo_name" (count $to_untrack) $removed_abs
        for warning in $skipped_not_tracked
            set present_args $present_args --warning "$warning"
        end
        __gitx_present_untrack $present_args
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

        set -l present_args 1 "$repo_name" (count $to_untrack) $removed_abs
        for warning in $skipped_not_tracked
            set present_args $present_args --warning "$warning"
        end
        __gitx_present_untrack $present_args
        return 0
    end

    if test (count $remove_entries) -eq 0
        set -l present_args 0 "$repo_name" (count $to_untrack) $removed_abs
        for warning in $skipped_not_tracked
            set present_args $present_args --warning "$warning"
        end
        __gitx_present_untrack $present_args
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
        __gitx_present_problem "gitx-untrack" "$repo_name" 0 "Failed to create exclude backup" "$exclude.bak"
        return 1
    end
    set run_cmds $run_cmds (string join -- ' ' (string escape -- cp "$exclude" "$exclude.bak"))

    mv "$tmp" "$exclude"
    or begin
        rm -f "$tmp"
        __gitx_present_problem "gitx-untrack" "$repo_name" 0 "Failed to update exclude file" "$exclude"
        return 1
    end
    set run_cmds $run_cmds "rewrite $exclude (without removed entries)"

    set -l present_args 0 "$repo_name" (count $to_untrack) $removed_abs
    for warning in $skipped_not_tracked
        set present_args $present_args --warning "$warning"
    end
    __gitx_present_untrack $present_args
end
