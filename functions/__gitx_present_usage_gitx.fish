function __gitx_present_usage_gitx_repo_modes --description 'Shared single-repo/all-repos usage lines for gitx presenters'
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
    printf "gitx "
    set_color yellow
    set_color --bold
    printf "<repo>"
    set_color normal
    set_color cyan
    printf " <git args...> "
    set_color brblack
    printf "# single repo\n"
    set_color normal

    printf "    "
    set_color cyan
    printf "gitx        <git args...> "
    set_color brblack
    printf "# all repos\n"
    set_color normal

    echo
end

function __gitx_present_usage_gitx --description 'Presenter for gitx usage scenarios'
    # Parameters:
    # $argv[1] - mode: with-repos | no-repos | missing-repos-dir | no-git-args
    # Remaining args depend on mode.

    if test (count $argv) -lt 1
        echo "Error: __gitx_present_usage_gitx requires at least 1 argument" >&2
        return 1
    end

    set -l mode $argv[1]

    switch "$mode"
        case 'with-repos'
            if test (count $argv) -lt 2
                echo "Error: __gitx_present_usage_gitx with-repos requires at least 1 repo name" >&2
                return 1
            end

            set -l repo_names $argv[2..-1]
            __gitx_present_usage_gitx_repo_modes

            set_color cyan
            printf "  Available repos:\n"
            set_color yellow
            set_color --bold
            for name in $repo_names
                printf "    %s\n" "$name"
            end
            set_color normal

            echo
            return 0

        case 'no-repos'
            if test (count $argv) -ne 2
                echo "Error: __gitx_present_usage_gitx no-repos requires exactly 1 path argument" >&2
                return 1
            end

            set -l repos_dir $argv[2]
            __gitx_present_usage_gitx_repo_modes

            printf "  "
            set_color cyan
            printf "No repos found in "
            set_color yellow
            set_color --bold
            printf "%s\n" "$repos_dir"
            set_color normal

            echo
            return 0

        case 'missing-repos-dir'
            if test (count $argv) -ne 2
                echo "Error: __gitx_present_usage_gitx missing-repos-dir requires exactly 1 path argument" >&2
                return 1
            end

            set -l repos_dir $argv[2]
            __gitx_present_usage_gitx_repo_modes

            printf "  "
            set_color cyan
            printf "Repos directory not found: "
            set_color yellow
            set_color --bold
            printf "%s\n" "$repos_dir"
            set_color normal

            echo
            return 0

        case 'no-git-args'
            if test (count $argv) -ne 2
                echo "Error: __gitx_present_usage_gitx no-git-args requires exactly 1 repo name argument" >&2
                return 1
            end

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
            printf "gitx <repo> "
            set_color yellow
            set_color --bold
            printf "<git args...>"
            set_color normal
            printf "\n"

            echo

            printf "  "
            set_color cyan
            printf "No git args specified\n"
            set_color normal

            echo
            return 0

        case '*'
            echo "Error: __gitx_present_usage_gitx unknown mode: $mode" >&2
            return 1
    end
end
