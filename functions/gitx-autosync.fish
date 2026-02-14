if not functions -q __gitx_autosync_load_config
    source (path dirname -- (status filename))/__gitx_autosync_load_config.fish
end

function __gitx_autosync_present_usage --description 'Show usage for gitx-autosync'
    __gitx_present_usage "gitx-autosync" \
        "gitx-autosync [--dry-run] on [--every <duration>] [--repo <name> ...]" \
        "gitx-autosync [--dry-run] off" \
        "gitx-autosync [--dry-run] status"
end

function __gitx_autosync_duration_to_seconds --description 'Convert autosync interval to seconds'
    if test (count $argv) -ne 1
        echo "Error: __gitx_autosync_duration_to_seconds requires exactly 1 argument" >&2
        return 1
    end

    set -l every $argv[1]
    if not string match -qr '^[1-9][0-9]*[mh]$' -- "$every"
        echo "Error: __gitx_autosync_duration_to_seconds: invalid duration: $every" >&2
        return 1
    end

    set -l unit (string sub -s -1 -- "$every")
    set -l amount_len (math (string length -- "$every") - 1)
    set -l amount (string sub -s 1 -l "$amount_len" -- "$every")

    if test "$unit" = "m"
        math "$amount * 60"
        return 0
    end

    math "$amount * 3600"
end

function __gitx_autosync_write_config --description 'Write autosync config file'
    if test (count $argv) -ne 6
        echo "Error: __gitx_autosync_write_config requires exactly 6 arguments" >&2
        return 1
    end

    set -l config_path $argv[1]
    set -l enabled $argv[2]
    set -l every $argv[3]
    set -l scope $argv[4]
    set -l repos_csv $argv[5]
    set -l backend $argv[6]

    set -l config_dir (path dirname -- "$config_path")
    command mkdir -p "$config_dir"
    or return 1

    command printf '%s\n' \
        "enabled=$enabled" \
        "every=$every" \
        "scope=$scope" \
        "repos=$repos_csv" \
        "backend=$backend" > "$config_path"
end

function __gitx_autosync_write_runner --description 'Write autosync runner script'
    if test (count $argv) -ne 1
        echo "Error: __gitx_autosync_write_runner requires exactly 1 argument" >&2
        return 1
    end

    set -l runner_path $argv[1]
    set -l autosync_dir (path dirname -- "$runner_path")

    command mkdir -p "$autosync_dir"
    or return 1

    command printf '%s\n' \
        '#!/usr/bin/env fish' \
        'set -l autosync_dir "$HOME/.gitx/autosync"' \
        'command mkdir -p "$autosync_dir" >/dev/null 2>/dev/null' \
        'set -l log_path "$autosync_dir/"(command date +%Y%m%d)".log"' \
        'if not functions -q __gitx_autosync_run' \
        '    if test -f "$HOME/.config/fish/functions/__gitx_autosync_run.fish"' \
        '        source "$HOME/.config/fish/functions/__gitx_autosync_run.fish"' \
        '    end' \
        'end' \
        'if functions -q __gitx_autosync_run' \
        '    __gitx_autosync_run >> "$log_path" 2>&1' \
        'else' \
        '    command printf "%s\n" "Error: __gitx_autosync_run function not found" >> "$log_path"' \
        'end' \
        'set -l log_paths (command find "$autosync_dir" -maxdepth 1 -type f -name "*.log" 2>/dev/null)' \
        'if test (count $log_paths) -gt 30' \
        '    set -l sorted_log_paths (string split "\n" -- (command printf "%s\n" $log_paths | command sort))' \
        '    set -l remove_count (math (count $sorted_log_paths) - 30)' \
        '    for old_log_path in $sorted_log_paths[1..$remove_count]' \
        '        command rm -f -- "$old_log_path" >/dev/null 2>/dev/null' \
        '    end' \
        'end' > "$runner_path"
end

function __gitx_autosync_write_launchd_plist --description 'Write launchd autosync plist'
    if test (count $argv) -ne 4
        echo "Error: __gitx_autosync_write_launchd_plist requires exactly 4 arguments" >&2
        return 1
    end

    set -l plist_path $argv[1]
    set -l runner_path $argv[2]
    set -l interval_seconds $argv[3]
    set -l fish_path $argv[4]

    set -l launch_agents_dir (path dirname -- "$plist_path")
    command mkdir -p "$launch_agents_dir"
    or return 1

    command printf '%s\n' \
        '<?xml version="1.0" encoding="UTF-8"?>' \
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
        '<plist version="1.0">' \
        '  <dict>' \
        '    <key>Label</key><string>com.gitx.autosync</string>' \
        '    <key>ProgramArguments</key>' \
        '    <array>' \
        '      <string>/usr/bin/env</string>' \
        "      <string>$fish_path</string>" \
        "      <string>$runner_path</string>" \
        '    </array>' \
        "    <key>StartInterval</key><integer>$interval_seconds</integer>" \
        '    <key>RunAtLoad</key><true/>' \
        '    <key>StandardOutPath</key><string>/dev/null</string>' \
        '    <key>StandardErrorPath</key><string>/dev/null</string>' \
        '  </dict>' \
        '</plist>' > "$plist_path"
end

function __gitx_autosync_write_systemd_units --description 'Write systemd user autosync unit files'
    if test (count $argv) -ne 5
        echo "Error: __gitx_autosync_write_systemd_units requires exactly 5 arguments" >&2
        return 1
    end

    set -l service_path $argv[1]
    set -l timer_path $argv[2]
    set -l runner_path $argv[3]
    set -l every $argv[4]
    set -l fish_path $argv[5]

    set -l systemd_dir (path dirname -- "$service_path")
    command mkdir -p "$systemd_dir"
    or return 1

    command printf '%s\n' \
        '[Unit]' \
        'Description=Run gitx autosync cycle' \
        '' \
        '[Service]' \
        'Type=oneshot' \
        "ExecStart=/usr/bin/env \"$fish_path\" \"$runner_path\"" > "$service_path"
    or return 1

    command printf '%s\n' \
        '[Unit]' \
        'Description=Run gitx autosync every configured interval' \
        '' \
        '[Timer]' \
        'OnBootSec=30s' \
        "OnUnitActiveSec=$every" \
        'Persistent=true' \
        '' \
        '[Install]' \
        'WantedBy=timers.target' > "$timer_path"
end

function __gitx_autosync_resolve_fish_path --description 'Resolve absolute path for fish binary'
    set -l fish_path (command -s fish)
    if test $status -ne 0 -o -z "$fish_path"
        return 1
    end

    if not test -x "$fish_path"
        return 1
    end

    echo "$fish_path"
end

function __gitx_autosync_require_systemd_user --description 'Validate systemd --user availability'
    if test (count $argv) -ne 1
        echo "Error: __gitx_autosync_require_systemd_user requires exactly 1 argument" >&2
        return 1
    end

    set -l dry_run $argv[1]

    if not command -q systemctl
        __gitx_present_problem "gitx-autosync" "-" "$dry_run" "systemctl command not found" "Linux autosync requires systemd --user"
        return 1
    end

    command systemctl --user show-environment >/dev/null 2>/dev/null
    if test $status -ne 0
        __gitx_present_problem "gitx-autosync" "-" "$dry_run" "systemd --user is unavailable" "Start a login session with systemd --user and retry"
        return 1
    end

    return 0
end

function gitx-autosync --description 'Enable, disable, or check periodic gitx commit and push'
    argparse 'n/dry-run' 'e/every=' 'r/repo=+' -- $argv
    or begin
        __gitx_autosync_present_usage >&2
        return 1
    end

    if test (count $argv) -ne 1
        __gitx_autosync_present_usage >&2
        return 1
    end

    set -l dry_run 0
    if set -q _flag_dry_run
        set dry_run 1
    end

    set -l mode_raw $argv[1]
    set -l mode
    switch "$mode_raw"
        case 'on' 'true' '1'
            set mode on
        case 'off' 'false' '0'
            set mode off
        case 'status'
            set mode status
        case '*'
            __gitx_autosync_present_usage >&2
            return 1
    end

    if test "$mode" != "on"
        if set -q _flag_every; or set -q _flag_repo
            __gitx_autosync_present_usage >&2
            return 1
        end
    end

    set -l current_platform (command uname)
    set -l backend
    switch "$current_platform"
        case 'Darwin'
            set backend launchd
        case 'Linux'
            set backend systemd-user
        case '*'
            __gitx_present_problem "gitx-autosync" "-" "$dry_run" "Unsupported platform" "$current_platform"
            return 1
    end

    if test "$backend" = "systemd-user"
        __gitx_autosync_require_systemd_user "$dry_run"
        or return 1
    end

    set -l autosync_dir "$HOME/.gitx/autosync"
    set -l config_path "$autosync_dir/config"
    set -l runner_path "$autosync_dir/run.fish"

    if test "$mode" = "on"
        set -l every 15m
        if set -q _flag_every
            set every "$_flag_every"
        end

        if not string match -qr '^[1-9][0-9]*[mh]$' -- "$every"
            __gitx_present_problem "gitx-autosync" "-" "$dry_run" "Invalid --every value" "Use minutes or hours, e.g. 15m or 2h"
            return 1
        end

        set -l scope all
        set -l repo_names
        if set -q _flag_repo
            set scope selected

            for repo_name in $_flag_repo
                if contains -- "$repo_name" $repo_names
                    continue
                end

                set -l repo "$HOME/.gitx/repos/$repo_name/repo"
                if not test -d "$repo"
                    __gitx_present_problem "gitx-autosync" "$repo_name" "$dry_run" "Repo not found" "$repo"
                    return 1
                end

                set repo_names $repo_names "$repo_name"
            end
        end

        if test "$dry_run" = "1"
            __gitx_present_autosync on 1 "$backend" "$every" "$scope" $repo_names
            return 0
        end

        set -l repos_csv ""
        if test "$scope" = "selected"
            set repos_csv (string join ',' -- $repo_names)
        end

        set -l fish_path (__gitx_autosync_resolve_fish_path)
        if test $status -ne 0
            __gitx_present_problem "gitx-autosync" "-" 0 "Fish binary not found" "Install fish and ensure it is available in PATH"
            return 1
        end

        __gitx_autosync_write_runner "$runner_path"
        or begin
            __gitx_present_problem "gitx-autosync" "-" 0 "Failed to write autosync runner" "$runner_path"
            return 1
        end

        if test "$backend" = "launchd"
            set -l uid (command id -u)
            set -l plist_path "$HOME/Library/LaunchAgents/com.gitx.autosync.plist"
            set -l every_seconds (__gitx_autosync_duration_to_seconds "$every")

            __gitx_autosync_write_launchd_plist "$plist_path" "$runner_path" "$every_seconds" "$fish_path"
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to write launchd plist" "$plist_path"
                return 1
            end

            command launchctl bootout "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null

            command launchctl enable "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to enable launchd agent" "com.gitx.autosync"
                return 1
            end

            command launchctl bootstrap "gui/$uid" "$plist_path" >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to bootstrap launchd agent" "$plist_path"
                return 1
            end

            command launchctl kickstart -k "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to start launchd agent" "com.gitx.autosync"
                return 1
            end
        else
            set -l service_path "$HOME/.config/systemd/user/gitx-autosync.service"
            set -l timer_path "$HOME/.config/systemd/user/gitx-autosync.timer"

            __gitx_autosync_write_systemd_units "$service_path" "$timer_path" "$runner_path" "$every" "$fish_path"
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to write systemd user units" "$HOME/.config/systemd/user"
                return 1
            end

            command systemctl --user daemon-reload >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to reload systemd user daemon"
                return 1
            end

            command systemctl --user enable --now gitx-autosync.timer >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to enable systemd user timer" "gitx-autosync.timer"
                return 1
            end
        end

        __gitx_autosync_write_config "$config_path" 1 "$every" "$scope" "$repos_csv" "$backend"
        or begin
            if test "$backend" = "launchd"
                set -l uid (command id -u)
                command launchctl disable "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
                command launchctl bootout "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
            else
                set -l timer_path "$HOME/.config/systemd/user/gitx-autosync.timer"
                if test -f "$timer_path"
                    command systemctl --user disable --now gitx-autosync.timer >/dev/null 2>/dev/null
                end
            end

            __gitx_present_problem "gitx-autosync" "-" 0 "Failed to write autosync config" "$config_path"
            return 1
        end

        __gitx_present_autosync on 0 "$backend" "$every" "$scope" $repo_names
        return 0
    end

    __gitx_autosync_load_config "$config_path" "$backend"
    or begin
        __gitx_present_problem "gitx-autosync" "-" "$dry_run" "Failed to read autosync config" "$config_path"
        return 1
    end

    if test "$mode" = "off"
        if test "$dry_run" = "1"
            __gitx_present_autosync off 1 "$backend"
            return 0
        end

        if test "$backend" = "launchd"
            set -l uid (command id -u)
            set -l was_active 0
            command launchctl print "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
            if test $status -eq 0
                set was_active 1
            end

            command launchctl disable "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
            or begin
                __gitx_present_problem "gitx-autosync" "-" 0 "Failed to disable launchd agent" "com.gitx.autosync"
                return 1
            end

            if test $was_active -eq 1
                command launchctl bootout "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
                or begin
                    __gitx_present_problem "gitx-autosync" "-" 0 "Failed to stop launchd agent" "com.gitx.autosync"
                    return 1
                end
            end
        else
            set -l timer_path "$HOME/.config/systemd/user/gitx-autosync.timer"
            if test -f "$timer_path"
                command systemctl --user disable --now gitx-autosync.timer >/dev/null 2>/dev/null
                or begin
                    __gitx_present_problem "gitx-autosync" "-" 0 "Failed to disable systemd user timer" "gitx-autosync.timer"
                    return 1
                end
            end
        end

        __gitx_autosync_write_config "$config_path" 0 "$__gitx_autosync_cfg_every" "$__gitx_autosync_cfg_scope" "$__gitx_autosync_cfg_repos" "$backend"
        or begin
            __gitx_present_problem "gitx-autosync" "-" 0 "Failed to update autosync config" "$config_path"
            return 1
        end

        __gitx_present_autosync off 0 "$backend"
        return 0
    end

    set -l enabled_status "$__gitx_autosync_cfg_enabled"
    set -l active_status 0

    if test "$backend" = "launchd"
        set -l uid (command id -u)

        command launchctl print "gui/$uid/com.gitx.autosync" >/dev/null 2>/dev/null
        if test $status -eq 0
            set active_status 1
        end

        set -l disabled_lines (command launchctl print-disabled "gui/$uid" 2>/dev/null)
        for line in $disabled_lines
            if string match -qr '"com\.gitx\.autosync" => (enabled|false)' -- "$line"
                set enabled_status 1
                break
            end

            if string match -qr '"com\.gitx\.autosync" => (disabled|true)' -- "$line"
                set enabled_status 0
                break
            end
        end
    else
        set -l enabled_output (command systemctl --user is-enabled gitx-autosync.timer 2>/dev/null)
        if test "$enabled_output" = "enabled"
            set enabled_status 1
        else
            set enabled_status 0
        end

        set -l active_output (command systemctl --user is-active gitx-autosync.timer 2>/dev/null)
        if test "$active_output" = "active"
            set active_status 1
        else
            set active_status 0
        end
    end

    set -l repo_names
    if test "$__gitx_autosync_cfg_scope" = "selected" -a -n "$__gitx_autosync_cfg_repos"
        set repo_names (string split ',' -- "$__gitx_autosync_cfg_repos")
    end

    if test "$__gitx_autosync_cfg_scope" = "selected" -a (count $repo_names) -eq 0
        __gitx_present_problem "gitx-autosync" "-" "$dry_run" "Invalid autosync config" "scope=selected requires repos; re-run gitx-autosync on [--repo <name> ...]"
        return 1
    end

    __gitx_present_autosync status "$dry_run" "$backend" "$enabled_status" "$active_status" "$__gitx_autosync_cfg_every" "$__gitx_autosync_cfg_scope" $repo_names
end
