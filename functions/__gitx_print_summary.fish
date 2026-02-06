function __gitx_print_summary --description 'Print standardized summary key/value lines with colors'
    # Skip empty summaries
    if test (count $argv) -eq 0
        return 0
    end

    set -l i 1
    while test $i -le (count $argv)
        set -l key $argv[$i]
        set -l value ""

        if test (math $i + 1) -le (count $argv)
            set value $argv[(math $i + 1)]
        end

        # Determine color for value based on context
        set -l value_color normal
        
        # Check for success/failure indicators (case-insensitive)
        if string match -q -r -i '^(yes|1|true|ok)$' -- $value
            set value_color green
        else if string match -q -r -i '^(no|0|false|fail(ed|ure)?)$' -- $value
            set value_color red
        else if string match -q -r '^[0-9]+$' -- $value
            # Numbers with specific meanings
            if test $value -gt 0
                if string match -q -r -i "fail|error" -- $key
                    set value_color red
                else if string match -q -r -i "track|stage|commit|ok|success" -- $key
                    set value_color green
                end
            else
                # Zero can be bad in some contexts
                if string match -q -r -i "track|stage|commit" -- $key
                    set value_color red
                end
            end
        end

        # Print key in dim color
        set_color brblack
        printf "  %s: " "$key"
        set_color normal
        
        # Print value in appropriate color
        if test -n "$value"
            set_color $value_color
            printf '%s\n' "$value"
            set_color normal
        else
            echo
        end
        
        set i (math $i + 2)
    end

    echo
end
