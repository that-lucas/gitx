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
    
    # Empty line before
    echo
    
    # Display mode and message
    if test $dry_run -eq 1
        # Dry-run mode: cyan icon and text, then grey path
        set_color cyan
        printf "◉ Dry-run\n"
        set_color normal
        printf "Bare repo created at "
        set_color brblack
        printf "%s\n" "$repo_path"
        set_color normal
    else
        # Success mode: green icon, then message with green path
        set_color green
        printf "✓ "
        set_color normal
        printf "Bare repo created at "
        set_color green
        printf "%s\n" "$repo_path"
        set_color normal
    end
    
    # Empty line after message
    echo
    
    # Show next step (for both dry-run and actual)
    if test -n "$repo_name"
        printf "Next: gitx-track %s file [glob …]\n" "$repo_name"
    end
    
    # Empty line at end
    echo
end
