function __gitx_present_passthrough --description 'Presenter for gitx passthrough command output'
    # Parameters:
    # $argv[1] - success (1 for success, 0 for failure)
    # $argv[2] - repo_name
    # $argv[3..-1] - output lines (variadic)
    
    if test (count $argv) -lt 2
        echo "Error: __gitx_present_passthrough requires at least 2 arguments" >&2
        return 1
    end
    
    set -l success $argv[1]
    set -l repo_name $argv[2]
    set -l output_lines $argv[3..-1]
    
    # Determine icon and color based on success
    set -l icon
    set -l result_color
    if test $success -eq 1
        # Success: green checkmark
        set icon "✓ "
        set result_color green
    else
        # Failure: red X
        set icon "✗ "
        set result_color red
    end
    
    # Empty line before output
    echo
    
    # Display icon + "Repo: {name}"
    set_color $result_color
    printf "%s" "$icon"
    set_color normal
    printf "Repo: "
    set_color --bold $result_color
    printf "%s\n" "$repo_name"
    set_color normal
    
    # Display output lines indented
    if test (count $output_lines) -gt 0
        for line in $output_lines
            set_color --bold $result_color
            printf "    %s\n" "$line"
            set_color normal
        end
    end
    
    # Empty line after output
    echo
end
