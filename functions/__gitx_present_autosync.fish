function __gitx_present_autosync --description 'Presenter for gitx-autosync command output'
    # Modes:
    # on <dry_run> <backend> <every> <scope> [repo...]
    # off <dry_run> <backend>
    # status <dry_run> <backend> <enabled> <active> <every> <scope> [repo...]

    if test (count $argv) -lt 1
        echo "Error: __gitx_present_autosync requires at least 1 argument" >&2
        return 1
    end

    set -l mode $argv[1]

    switch "$mode"
        case 'on'
            if test (count $argv) -lt 5
                echo "Error: __gitx_present_autosync on requires at least 4 arguments after mode" >&2
                return 1
            end

            set -l dry_run $argv[2]
            set -l backend $argv[3]
            set -l every $argv[4]
            set -l scope $argv[5]
            set -l repo_names
            if test (count $argv) -gt 5
                set repo_names $argv[6..-1]
            end

            if test "$dry_run" != "0" -a "$dry_run" != "1"
                echo "Error: __gitx_present_autosync on dry_run must be 0 or 1" >&2
                return 1
            end

            if test "$backend" != "launchd" -a "$backend" != "systemd-user"
                echo "Error: __gitx_present_autosync on backend must be launchd or systemd-user" >&2
                return 1
            end

            if test "$scope" != "all" -a "$scope" != "selected"
                echo "Error: __gitx_present_autosync on scope must be all or selected" >&2
                return 1
            end

            if test "$scope" = "all" -a (count $repo_names) -gt 0
                echo "Error: __gitx_present_autosync on all scope takes no repo names" >&2
                return 1
            end

            if test "$scope" = "selected" -a (count $repo_names) -eq 0
                echo "Error: __gitx_present_autosync on selected scope requires at least 1 repo name" >&2
                return 1
            end

            set -l icon "✓ "
            set -l result_color green
            if test "$dry_run" = "1"
                set icon "◉ "
                set result_color brblack
            end

            echo

            if test "$dry_run" = "1"
                set_color cyan
                printf "  Dry-run\n"
                set_color normal
            end

            set_color $result_color
            set_color --bold
            printf "%s" "$icon"
            set_color normal
            printf "Autosync enabled\n"

            printf "  Backend: "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$backend"
            set_color normal

            printf "  Every: "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$every"
            set_color normal

            printf "  Repos: "
            set_color $result_color
            set_color --bold
            if test "$scope" = "all"
                printf "all\n"
            else
                printf "%d\n" (count $repo_names)
            end
            set_color normal

            if test "$scope" = "selected"
                for repo_name in $repo_names
                    printf "    "
                    set_color $result_color
                    set_color --bold
                    printf "%s\n" "$repo_name"
                    set_color normal
                end
            end

            if test "$dry_run" = "0"
                echo
                printf "  Next: "
                set_color cyan
                printf "gitx-autosync status\n"
                set_color normal
            end

            echo
            return 0

        case 'off'
            if test (count $argv) -ne 3
                echo "Error: __gitx_present_autosync off requires exactly 2 arguments after mode" >&2
                return 1
            end

            set -l dry_run $argv[2]
            set -l backend $argv[3]

            if test "$dry_run" != "0" -a "$dry_run" != "1"
                echo "Error: __gitx_present_autosync off dry_run must be 0 or 1" >&2
                return 1
            end

            if test "$backend" != "launchd" -a "$backend" != "systemd-user"
                echo "Error: __gitx_present_autosync off backend must be launchd or systemd-user" >&2
                return 1
            end

            set -l icon "✓ "
            set -l result_color green
            if test "$dry_run" = "1"
                set icon "◉ "
                set result_color brblack
            end

            echo

            if test "$dry_run" = "1"
                set_color cyan
                printf "  Dry-run\n"
                set_color normal
            end

            set_color $result_color
            set_color --bold
            printf "%s" "$icon"
            set_color normal
            printf "Autosync disabled\n"

            printf "  Backend: "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$backend"
            set_color normal

            echo
            return 0

        case 'status'
            if test (count $argv) -lt 7
                echo "Error: __gitx_present_autosync status requires at least 6 arguments after mode" >&2
                return 1
            end

            set -l dry_run $argv[2]
            set -l backend $argv[3]
            set -l enabled $argv[4]
            set -l active $argv[5]
            set -l every $argv[6]
            set -l scope $argv[7]
            set -l repo_names
            if test (count $argv) -gt 7
                set repo_names $argv[8..-1]
            end

            if test "$dry_run" != "0" -a "$dry_run" != "1"
                echo "Error: __gitx_present_autosync status dry_run must be 0 or 1" >&2
                return 1
            end

            if test "$backend" != "launchd" -a "$backend" != "systemd-user"
                echo "Error: __gitx_present_autosync status backend must be launchd or systemd-user" >&2
                return 1
            end

            if test "$enabled" != "0" -a "$enabled" != "1"
                echo "Error: __gitx_present_autosync status enabled must be 0 or 1" >&2
                return 1
            end

            if test "$active" != "0" -a "$active" != "1"
                echo "Error: __gitx_present_autosync status active must be 0 or 1" >&2
                return 1
            end

            if test "$scope" != "all" -a "$scope" != "selected"
                echo "Error: __gitx_present_autosync status scope must be all or selected" >&2
                return 1
            end

            if test "$scope" = "all" -a (count $repo_names) -gt 0
                echo "Error: __gitx_present_autosync status all scope takes no repo names" >&2
                return 1
            end

            if test "$scope" = "selected" -a (count $repo_names) -eq 0
                echo "Error: __gitx_present_autosync status selected scope requires at least 1 repo name" >&2
                return 1
            end

            set -l icon "◉ "
            set -l result_color brblack
            set -l status_hint
            if test "$enabled" = "1" -a "$active" = "1"
                set icon "✓ "
                set result_color green
            else if test "$enabled" = "1" -a "$active" = "0"
                set icon "✗ "
                set result_color red
                set status_hint "Enabled but inactive. Re-run gitx-autosync on to refresh scheduler state."
            else if test "$enabled" = "0" -a "$active" = "1"
                set icon "✗ "
                set result_color red
                set status_hint "Active while disabled. Run gitx-autosync off again to stop the scheduler."
            end

            echo

            if test "$dry_run" = "1"
                set_color cyan
                printf "  Dry-run\n"
                set_color normal
            end

            set_color $result_color
            set_color --bold
            printf "%s" "$icon"
            set_color normal
            printf "Autosync status\n"

            printf "  Backend: "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$backend"
            set_color normal

            printf "  Enabled: "
            set_color $result_color
            set_color --bold
            if test "$enabled" = "1"
                printf "yes\n"
            else
                printf "no\n"
            end
            set_color normal

            printf "  Active: "
            set_color $result_color
            set_color --bold
            if test "$active" = "1"
                printf "yes\n"
            else
                printf "no\n"
            end
            set_color normal

            printf "  Every: "
            set_color $result_color
            set_color --bold
            printf "%s\n" "$every"
            set_color normal

            printf "  Repos: "
            set_color $result_color
            set_color --bold
            if test "$scope" = "all"
                printf "all\n"
            else
                printf "%d\n" (count $repo_names)
            end
            set_color normal

            if test "$scope" = "selected"
                for repo_name in $repo_names
                    printf "    "
                    set_color $result_color
                    set_color --bold
                    printf "%s\n" "$repo_name"
                    set_color normal
                end
            end

            if test -n "$status_hint"
                echo
                printf "  Hint: "
                set_color cyan
                printf "%s\n" "$status_hint"
                set_color normal
            end

            echo
            return 0

        case '*'
            echo "Error: __gitx_present_autosync unknown mode: $mode" >&2
            return 1
    end
end
