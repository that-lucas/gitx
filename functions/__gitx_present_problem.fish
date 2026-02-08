function __gitx_present_problem --description 'Presenter for runtime command errors'
    # Parameters:
    # $argv[1] - command_name
    # $argv[2] - repo_name ("-" when not applicable)
    # $argv[3] - dry_run (1 or 0)
    # $argv[4] - headline
    # $argv[5..] - details (optional)

    if test (count $argv) -lt 4
        echo "Error: __gitx_present_problem requires at least 4 arguments" >&2
        return 1
    end

    set -l command_name $argv[1]
    set -l repo_name $argv[2]
    set -l dry_run $argv[3]
    set -l headline $argv[4]
    set -l details

    if test (count $argv) -ge 5
        set details $argv[5..-1]
    end

    echo

    if test "$dry_run" = "1"
        set_color cyan
        printf "  Dry-run\n"
        set_color normal
    end

    set_color red
    set_color --bold
    printf "✗ "
    set_color normal
    printf "%s\n" "$headline"

    printf "  Command: "
    set_color red
    set_color --bold
    printf "%s\n" "$command_name"
    set_color normal

    if test -n "$repo_name" -a "$repo_name" != "-"
        printf "  Repo: "
        set_color red
        set_color --bold
        printf "%s\n" "$repo_name"
        set_color normal
    end

    if test (count $details) -gt 0
        echo
        printf "  Details:\n"
        for detail in $details
            set_color red
            set_color --bold
            printf "    %s\n" "$detail"
            set_color normal
        end
    end

    echo
end
