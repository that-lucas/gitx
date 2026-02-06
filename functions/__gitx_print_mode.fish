function __gitx_print_mode --description 'Print leading blank line and mode/result heading'
    if test (count $argv) -lt 1
        return 1
    end

    set -l mode $argv[1]
    
    echo
    # Use icons and bold text for modern CLI feel
    if string match -q -r "Dry-run" -- $mode
        set_color cyan
        printf "◉ "
        set_color --bold
        printf "%s\n" $mode
        set_color normal
    else if string match -q -r -i "result|complete|success" -- $mode
        set_color green
        printf "✓ "
        set_color --bold
        printf "%s\n" $mode
        set_color normal
    else if string match -q -r -i "fail|error" -- $mode
        set_color red
        printf "✗ "
        set_color --bold
        printf "%s\n" $mode
        set_color normal
    else
        set_color --bold
        printf "%s\n" $mode
        set_color normal
    end
    echo
end
