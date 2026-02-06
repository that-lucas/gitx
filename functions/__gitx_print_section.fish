function __gitx_print_section --description 'Print a named section with colored output'
    if test (count $argv) -lt 1
        return 1
    end

    set -l title $argv[1]
    set -e argv[1]

    # Determine color based on title/context
    set -l label_color brblack
    set -l value_color normal
    
    if string match -q -r -i "error|fail" -- $title
        set value_color red
    else if string match -q -r -i "success|tracked|staged|committed" -- $title
        set value_color green
    end

    # Print title in dim color
    set_color $label_color
    printf "%s: " "$title"
    set_color normal
    
    # Print values
    if test (count $argv) -eq 0
        set_color $value_color
        printf "(none)\n"
        set_color normal
    else if test (count $argv) -eq 1
        set_color $value_color
        printf "%s\n" "$argv[1]"
        set_color normal
    else
        # Multiple items - show count in color, then list
        set_color $value_color
        printf "%d\n" (count $argv)
        set_color normal
        for item in $argv
            set_color brblack
            printf "  • "
            set_color $value_color
            printf "%s\n" "$item"
            set_color normal
        end
    end
    echo
end
