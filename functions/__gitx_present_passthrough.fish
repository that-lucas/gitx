function __gitx_present_passthrough --description 'Presenter for passthrough framing and status'
    # Modes:
    # begin
    # entry-start <repo_name>
    # entry-end <success> <repo_name>

    if test (count $argv) -lt 1
        echo "Error: __gitx_present_passthrough requires at least 1 argument" >&2
        return 1
    end

    set -l mode $argv[1]

    switch "$mode"
        case 'begin'
            if test (count $argv) -ne 1
                echo "Error: __gitx_present_passthrough begin takes no extra arguments" >&2
                return 1
            end
            # Exactly one empty line before all entries.
            echo
            return 0

        case 'entry-start'
            if test (count $argv) -ne 2
                echo "Error: __gitx_present_passthrough entry-start requires exactly 1 argument" >&2
                return 1
            end

            set -l repo_name $argv[2]
            set_color brblack
            set_color --bold
            printf "◉ "
            set_color normal
            printf "Repo: "
            set_color brblack
            set_color --bold
            printf "%s\n" "$repo_name"
            set_color normal
            return 0

        case 'entry-end'
            if test (count $argv) -ne 3
                echo "Error: __gitx_present_passthrough entry-end requires exactly 2 arguments" >&2
                return 1
            end

            set -l success $argv[2]
            if test "$success" != "0" -a "$success" != "1"
                echo "Error: __gitx_present_passthrough entry-end success must be 0 or 1" >&2
                return 1
            end

            set -l icon
            set -l result_color
            if test "$success" = "1"
                set icon "✓ "
                set result_color green
            else
                set icon "✗ "
                set result_color red
            end

            set_color $result_color
            set_color --bold
            printf "%s" "$icon"
            if test "$success" = "1"
                printf "Done\n"
            else
                printf "Failed\n"
            end
            set_color normal

            # Exactly one empty line after each entry.
            echo
            return 0

        case '*'
            echo "Error: __gitx_present_passthrough unknown mode: $mode" >&2
            return 1
    end
end
