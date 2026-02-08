function __gitx_present_usage --description 'Presenter for command usage/help output'
    # Parameters:
    # $argv[1] - command_name
    # $argv[2..] - usage/help lines

    if test (count $argv) -lt 2
        echo "Error: __gitx_present_usage requires at least 2 arguments" >&2
        return 1
    end

    set -l command_name $argv[1]
    set -l lines $argv[2..-1]

    echo

    set_color yellow
    set_color --bold
    printf "⚠ "
    set_color normal
    printf "Usage for "
    set_color yellow
    set_color --bold
    printf "%s\n" "$command_name"
    set_color normal

    for line in $lines
        if test -z "$line"
            echo
            continue
        end
        printf "  "
        set_color cyan
        printf "%s\n" "$line"
        set_color normal
    end

    echo
end
