function __gitx_present_commit --description 'Presenter for gitx-commit command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_name
    # $argv[3] - files_to_commit (number)
    # $argv[4] - commit_message
    
    if test (count $argv) -lt 4
        echo "Error: __gitx_present_commit requires 4 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_name $argv[2]
    set -l files_count $argv[3]
    set -l commit_message $argv[4]
    
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
        printf "Commit result\n"
        set_color normal
    end
    echo
    
    # Display message
    set_color brblack
    printf "Message: "
    set_color normal
    printf "%s\n" "$commit_message"
    echo
    
    # Display repo
    set_color brblack
    printf "  Repo: "
    set_color normal
    printf "%s\n" "$repo_name"
    
    # Display files count (green if > 0, red if 0)
    set_color brblack
    if test $dry_run -eq 1
        printf "  Files to commit: "
    else
        printf "  Files committed: "
    end
    set_color normal
    if test $files_count -gt 0
        set_color green
    else
        set_color red
    end
    printf "%d\n" $files_count
    set_color normal
    
    echo
    
    # Show next step only for successful non-dry-run commits
    if test $dry_run -eq 0 -a $files_count -gt 0
        printf "Next: gitx %s push\n" "$repo_name"
        echo
    end
end
