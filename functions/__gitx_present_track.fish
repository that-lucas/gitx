function __gitx_present_track --description 'Presenter for gitx-track command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_name
    # $argv[3] - items_tracked (number)
    # $argv[4] - items_staged (number, only for non-dry-run)
    # $argv[5..] - skipped_items (optional list for non-dry-run)
    
    if test (count $argv) -lt 3
        echo "Error: __gitx_present_track requires at least 3 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_name $argv[2]
    set -l items_tracked $argv[3]
    set -l items_staged 0
    set -l skipped_items
    
    if test $dry_run -eq 0
        if test (count $argv) -ge 4
            set items_staged $argv[4]
        end
        if test (count $argv) -ge 5
            set skipped_items $argv[5..-1]
        end
    end
    
    # Display mode
    if test $dry_run -eq 1
        set_color cyan
        printf "◉ "
        set_color --bold
        printf "Dry-run mode\n"
        set_color normal
    else
        set_color green
        printf "✓ "
        set_color --bold
        printf "Track result\n"
        set_color normal
    end
    echo
    
    # Display repo
    set_color brblack
    printf "  Repo: "
    set_color normal
    printf "%s\n" "$repo_name"
    
    # Display items tracked (green if > 0, red if 0)
    set_color brblack
    printf "  Items tracked: "
    set_color normal
    if test $items_tracked -gt 0
        set_color green
    else
        set_color red
    end
    printf "%d\n" $items_tracked
    set_color normal
    
    # Display items staged for non-dry-run
    if test $dry_run -eq 0
        set_color brblack
        printf "  Items staged: "
        set_color normal
        if test $items_staged -gt 0
            set_color green
        else
            set_color red
        end
        printf "%d\n" $items_staged
        set_color normal
    end
    
    echo
    
    # Show skipped items if any
    if test $dry_run -eq 0 -a (count $skipped_items) -gt 0
        set_color brblack
        printf "Skipped: "
        set_color normal
        printf "%d\n" (count $skipped_items)
        for item in $skipped_items
            set_color brblack
            printf "  • "
            set_color normal
            printf "%s\n" "$item"
        end
        echo
    end
    
    # Show next step only for non-dry-run
    if test $dry_run -eq 0
        printf "Next: gitx-commit %s\n" "$repo_name"
        echo
    end
end
