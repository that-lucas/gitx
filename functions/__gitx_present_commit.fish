function __gitx_present_commit --description 'Presenter for gitx-commit command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_name
    # $argv[3] - items_count (number of files committed/to commit)
    # $argv[4] - commit_message
    # $argv[5..] - file_paths (list of file paths)
    
    if test (count $argv) -lt 4
        echo "Error: __gitx_present_commit requires at least 4 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_name $argv[2]
    set -l items_count $argv[3]
    set -l commit_message $argv[4]
    if not string match -qr '^[0-9]+$' -- "$items_count"
        echo "Error: __gitx_present_commit items_count must be a non-negative integer" >&2
        return 1
    end

    set -l file_paths
    set -l warnings
    set -l reason
    set -l argc (count $argv)
    set -l idx 5

    if test "$items_count" -gt 0
        set -l file_end (math $idx + $items_count - 1)
        if test $file_end -gt $argc
            echo "Error: __gitx_present_commit missing file path arguments" >&2
            return 1
        end
        set file_paths $argv[$idx..$file_end]
        set idx (math $file_end + 1)
    end

    while test $idx -le $argc
        set -l token $argv[$idx]
        switch "$token"
            case '--warning'
                set idx (math $idx + 1)
                if test $idx -gt $argc
                    echo "Error: __gitx_present_commit missing value for --warning" >&2
                    return 1
                end
                set warnings $warnings "$argv[$idx]"
            case '--reason'
                set idx (math $idx + 1)
                if test $idx -gt $argc
                    echo "Error: __gitx_present_commit missing value for --reason" >&2
                    return 1
                end
                set reason "$argv[$idx]"
            case '*'
                echo "Error: __gitx_present_commit unknown optional argument: $token" >&2
                return 1
        end
        set idx (math $idx + 1)
    end
    
    # Determine icon and color based on dry_run and items_count
    # Dry-run always uses circle icon, regardless of count
    # 0 files is a noop (not error), so use green check with brblack color
    set -l icon "✓ "
    set -l result_color green
    
    if test $dry_run -eq 1
        # Dry-run: neutral circle icon, brblack color (always)
        set icon "◉ "
        set result_color brblack
    else if test $items_count -eq 0
        # Noop case (0 files): green check icon, but brblack color for content
        set icon "✓ "
        set result_color brblack
    end
    
    # Empty line before
    echo
    
    # Display mode header for dry-run
    if test $dry_run -eq 1
        set_color cyan
        printf "  Dry-run\n"
        set_color normal
    end
    
    # Display icon and "Files committed: {number}"
    # Always use "Files committed" label - mode is indicated by Dry-run header and icon
    set_color $result_color
    set_color --bold
    printf $icon
    set_color normal
    printf "Files committed: "
    set_color $result_color
    set_color --bold
    printf "%d\n" $items_count
    set_color normal
    
    # Display file paths (indented, bold result_color)
    if test $items_count -gt 0
        for filepath in $file_paths
            printf "    "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$filepath"
            set_color normal
        end
    end
    
    # Display message (indented by 2 spaces, only when items_count > 0)
    if test $items_count -gt 0
        echo
        printf "  Message: "
        set_color $result_color
        set_color --bold
        printf "%s\n" "$commit_message"
        set_color normal
    end

    # Show next step only for actual commits with items_count > 0
    if test $dry_run -eq 0 -a $items_count -gt 0
        echo
        printf "  Next: "
        set_color cyan
        printf "gitx "
        set_color green
        set_color --bold
        printf "%s" "$repo_name"
        set_color normal
        set_color cyan
        printf " push\n"
        set_color normal
    end
    
    # Empty line at end
    echo
end
