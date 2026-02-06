function __gitx_print_summary --description 'Print standardized summary key/value lines'
    echo "Summary:"

    set -l i 1
    while test $i -le (count $argv)
        set -l key $argv[$i]
        set -l value "(none)"

        if test (math $i + 1) -le (count $argv)
            set value $argv[(math $i + 1)]
        end

        printf "  %s: %s\n" "$key" "$value"
        set i (math $i + 2)
    end

    echo
end
