function __gitx_autosync_load_config --description 'Load autosync config into globals'
    if test (count $argv) -ne 2
        echo "Error: __gitx_autosync_load_config requires exactly 2 arguments" >&2
        return 1
    end

    set -l config_path $argv[1]
    set -l default_backend $argv[2]

    set -g __gitx_autosync_cfg_enabled 0
    set -g __gitx_autosync_cfg_every 15m
    set -g __gitx_autosync_cfg_scope all
    set -g __gitx_autosync_cfg_repos ""
    set -g __gitx_autosync_cfg_backend "$default_backend"

    if not test -f "$config_path"
        return 0
    end

    while read -l line
        set -l trimmed (string trim -- "$line")
        if test -z "$trimmed"
            continue
        end

        set -l parts (string split -m 1 '=' -- "$trimmed")
        if test (count $parts) -ne 2
            continue
        end

        set -l key $parts[1]
        set -l value $parts[2]

        switch "$key"
            case 'enabled'
                if test "$value" = "0" -o "$value" = "1"
                    set -g __gitx_autosync_cfg_enabled "$value"
                end
            case 'every'
                if string match -qr '^[1-9][0-9]*[mh]$' -- "$value"
                    set -g __gitx_autosync_cfg_every "$value"
                end
            case 'scope'
                if test "$value" = "all" -o "$value" = "selected"
                    set -g __gitx_autosync_cfg_scope "$value"
                end
            case 'repos'
                set -g __gitx_autosync_cfg_repos "$value"
            case 'backend'
                if test "$value" = "launchd" -o "$value" = "systemd-user"
                    set -g __gitx_autosync_cfg_backend "$value"
                end
        end
    end < "$config_path"

    return 0
end
