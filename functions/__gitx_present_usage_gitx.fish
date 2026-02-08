function __gitx_present_usage_gitx --description 'Presenter for gitx usage with optional repo list context'
    # Parameters:
    # $argv[1..] - repo_names

    if test (count $argv) -lt 1
        echo "Error: __gitx_present_usage_gitx requires at least 1 argument" >&2
        return 1
    end

    set -l repo_names $argv

    echo

    set_color yellow
    set_color --bold
    printf "⚠ "
    set_color normal
    printf "Usage for "
    set_color yellow
    set_color --bold
    printf "gitx\n"
    set_color normal

    printf "    "
    set_color cyan
    set_color --bold
    printf "gitx "
    set_color yellow
    set_color --bold
    printf "<repo>"
    set_color cyan
    set_color --bold
    printf " <git args...> # single repo\n"
    set_color normal

    printf "    "
    set_color cyan
    set_color --bold
    printf "gitx        <git args...> # all repos\n"
    set_color normal

    echo

    set_color cyan
    set_color --bold
    printf "  Available repos:\n"
    set_color yellow
    set_color --bold
    for name in $repo_names
        printf "    %s\n" "$name"
    end
    set_color normal

    echo
end
