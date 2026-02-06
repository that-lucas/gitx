function __gitx_print_mode --description 'Print leading blank line and mode/result heading'
    if test (count $argv) -lt 1
        return 1
    end

    echo
    echo $argv[1]
    echo
end
