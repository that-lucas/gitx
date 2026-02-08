function __gitx_present_passthrough_entry --description 'Render one gitx passthrough repo result'
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
    
    # Display icon + "Repo: {name}"
    set_color $result_color
    set_color --bold
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

    # Exactly one empty line after this entry.
    echo
end

function __gitx_present_passthrough --description 'Presenter for gitx passthrough command output'
    # Parameters:
    # $argv[1] - items_count
    # Repeated items:
    #   <success> <repo_name> <line_count> <line1..lineN>

    if test (count $argv) -lt 1
        echo "Error: __gitx_present_passthrough requires at least 1 argument" >&2
        return 1
    end

    set -l items_count $argv[1]
    if not string match -qr '^[0-9]+$' -- "$items_count"
        echo "Error: __gitx_present_passthrough items_count must be a non-negative integer" >&2
        return 1
    end

    if test "$items_count" -eq 0
        return 0
    end

    # Exactly one empty line before all entries.
    echo

    set -l argc (count $argv)
    set -l idx 2

    for item_index in (seq 1 $items_count)
        if test $idx -gt $argc
            echo "Error: __gitx_present_passthrough missing item fields" >&2
            return 1
        end
        set -l success $argv[$idx]
        set idx (math $idx + 1)

        if test $idx -gt $argc
            echo "Error: __gitx_present_passthrough missing repo_name field" >&2
            return 1
        end
        set -l repo_name $argv[$idx]
        set idx (math $idx + 1)

        if test $idx -gt $argc
            echo "Error: __gitx_present_passthrough missing line_count field" >&2
            return 1
        end
        set -l line_count $argv[$idx]
        set idx (math $idx + 1)

        if not string match -qr '^[0-9]+$' -- "$line_count"
            echo "Error: __gitx_present_passthrough line_count must be a non-negative integer" >&2
            return 1
        end

        set -l output_lines
        if test "$line_count" -gt 0
            set -l line_end (math $idx + $line_count - 1)
            if test $line_end -gt $argc
                echo "Error: __gitx_present_passthrough not enough line arguments for an item" >&2
                return 1
            end
            set output_lines $argv[$idx..$line_end]
            set idx (math $line_end + 1)
        end

        __gitx_present_passthrough_entry $success $repo_name $output_lines
        or return 1
    end

    if test $idx -le $argc
        echo "Error: __gitx_present_passthrough received extra trailing arguments" >&2
        return 1
    end
end
