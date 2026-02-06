function __gitx_color --description 'Output colored text for modern CLI'
    if test (count $argv) -lt 2
        return 1
    end

    set -l color $argv[1]
    set -l text $argv[2]

    # ANSI color codes
    switch $color
        case green success
            set_color green
        case red error fail failure
            set_color red
        case yellow warning
            set_color yellow
        case blue info
            set_color blue
        case cyan
            set_color cyan
        case gray muted dim
            set_color brblack
        case bold
            set_color --bold
        case reset normal
            set_color normal
        case '*'
            # Default color, no change
    end

    echo -n $text
    set_color normal
end
