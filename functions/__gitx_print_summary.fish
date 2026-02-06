function __gitx_print_summary --description 'Print standardized summary key/value lines'
    # Skip empty summaries
    if test (count $argv) -eq 0
        return 0
    end

    set_color brblack
    echo -n "─"
    set_color normal
    echo

    set -l i 1
    while test $i -le (count $argv)
        set -l key $argv[$i]
        set -l value ""

        if test (math $i + 1) -le (count $argv)
            set value $argv[(math $i + 1)]
        end

        # Determine color for value based on context
        set -l value_color normal
        
        # Check for success/failure indicators
        if string match -q -r '^(yes|1|true|ok)$' -- $value
            set value_color green
        else if string match -q -r '^(no|0|false|fails?|failed)$' -- $value
            set value_color red
        else if string match -q -r '^[0-9]+$' -- $value
            # Numbers with specific meanings
            if test $value -gt 0
                if string match -q -r -i "fail|error" -- $key
                    set value_color red
                else if string match -q -r -i "ok|success" -- $key
                    set value_color green
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
            echo $value
            set_color normal
        else
            echo
        end
        
        set i (math $i + 2)
    end

    echo
end
