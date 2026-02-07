function __gitx_present_untrack --description 'Presenter for gitx-untrack command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_name
    # $argv[3] - items_untracked (number)
    
    if test (count $argv) -lt 3
        echo "Error: __gitx_present_untrack requires 3 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_name $argv[2]
    set -l items_untracked $argv[3]
    
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
        printf "Untrack result\n"
        set_color normal
    end
    echo
    
    # Display repo
    set_color brblack
    printf "  Repo: "
    set_color normal
    printf "%s\n" "$repo_name"
    
    # Display items untracked (green if > 0, red if 0)
    set_color brblack
    printf "  Items untracked: "
    set_color normal
    if test $items_untracked -gt 0
        set_color green
    else
        set_color red
    end
    printf "%d\n" $items_untracked
    set_color normal
    
    echo
    
    # Show next step only for non-dry-run
    if test $dry_run -eq 0
        printf "Next: gitx-commit %s\n" "$repo_name"
        echo
    end
end
