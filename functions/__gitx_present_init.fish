function __gitx_present_init --description 'Presenter for gitx-init command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_path
    # $argv[3] - remote_url (optional, can be empty string)
    # $argv[4] - repo_name (for next step suggestion)
    
    if test (count $argv) -lt 3
        echo "Error: __gitx_present_init requires at least 3 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_path $argv[2]
    set -l remote_url $argv[3]
    set -l repo_name ""
    if test (count $argv) -ge 4
        set repo_name $argv[4]
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
        printf "Init result\n"
        set_color normal
    end
    echo
    
    # Display repo info
    set_color brblack
    printf "  Repo: "
    set_color normal
    printf "%s\n" "$repo_path"
    
    # Display remote if provided
    if test -n "$remote_url"
        set_color brblack
        printf "  Remote: "
        set_color normal
        printf "%s\n" "$remote_url"
    end
    
    echo
    
    # Show next step only for non-dry-run
    if test $dry_run -eq 0 -a -n "$repo_name"
        printf "Next: gitx-track %s <glob> [<glob-n>]\n" "$repo_name"
        echo
    end
end
