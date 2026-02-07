function __gitx_present_passthrough --description 'Presenter for gitx passthrough command output'
    # Parameters:
    # $argv[1] - success (1 for success, 0 for failure)
    # $argv[2] - repo_name
    # $argv[3] - output (raw command output)
    
    if test (count $argv) -lt 3
        echo "Error: __gitx_present_passthrough requires 3 arguments" >&2
        return 1
    end
    
    set -l success $argv[1]
    set -l repo_name $argv[2]
    set -l output $argv[3]
    
    # Display mode based on success
    if test $success -eq 1
        set_color green
        printf "✓ "
        set_color --bold
        printf "Success\n"
        set_color normal
    else
        set_color red
        printf "✗ "
        set_color --bold
        printf "Failed\n"
        set_color normal
    end
    echo
    
    # Display repo
    set_color brblack
    printf "Repo: "
    set_color normal
    printf "%s\n" "$repo_name"
    echo
    
    # Display raw output if present
    if test -n "$output"
        printf "%s\n" "$output"
        echo
    end
end
