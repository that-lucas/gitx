function __gitx_present_init --description 'Presenter for gitx-init command output'
    # Parameters:
    # $argv[1] - dry_run (1 or 0)
    # $argv[2] - repo_path
    # $argv[3] - remote_url (optional, can be empty string)
    # $argv[4] - repo_name (for next step suggestion)
    
    if test (count $argv) -lt 4
        echo "Error: __gitx_present_init requires at least 4 arguments" >&2
        return 1
    end
    
    set -l dry_run $argv[1]
    set -l repo_path $argv[2]
    set -l remote_url $argv[3]
    set -l repo_name $argv[4]
    
    # Determine icon and color based on dry_run
    set -l icon "✓ "
    set -l result_color green
    
    if test $dry_run -eq 1
        set icon "◉ "
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
    
    # Display icon and "Bare repo created at {path}"
    set_color $result_color
    set_color --bold
    printf $icon
    set_color normal
    printf "Bare repo created at "
    set_color $result_color
    set_color --bold
    printf "%s" "$repo_path"
    set_color normal
    if test -n "$remote_url"
        printf " ("
        set_color $result_color
        set_color --bold
        printf "%s" "$remote_url"
        set_color normal
        printf ")"
    end
    printf "\n"
    
    # Show next step (for both dry-run and actual)
    printf "  Next: "
    set_color cyan
    printf "gitx-track "
    set_color $result_color
    set_color --bold
    printf "%s" "$repo_name"
    set_color normal
    set_color cyan
    printf " <file-or-glob> [<file-or-glob> ...]\n"
    set_color normal
    
    # Empty line at end
    echo
end
