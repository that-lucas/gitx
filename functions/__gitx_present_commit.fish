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
    set -l file_paths
    
    if test (count $argv) -ge 5
        set file_paths $argv[5..-1]
    end
    
    # Determine icon and color based on dry_run and items_count
    # Special case: 0 files is a noop (not error), so always use green check
    # but use brblack color for content when count is 0
    set -l icon "✓ "
    set -l result_color green
    
    if test $dry_run -eq 1 -a $items_count -gt 0
        # Dry-run with files: neutral icon, brblack color
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
        printf "  Message: %s\n" "$commit_message"
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
