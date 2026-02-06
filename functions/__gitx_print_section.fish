function __gitx_print_section --description 'Print a named section with 4-space-indented items'
    if test (count $argv) -lt 1
        return 1
    end

    set -l title $argv[1]
    set -e argv[1]

    echo "$title:"
    if test (count $argv) -eq 0
        printf "  %s\n" "(none)"
    else
        for item in $argv
            printf "  %s\n" "$item"
        end
    end
    echo
end
