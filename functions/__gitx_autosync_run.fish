if not functions -q __gitx_autosync_load_config
    source (path dirname -- (status filename))/__gitx_autosync_load_config.fish
end

function __gitx_autosync_run --description 'Run one autosync cycle for configured gitx repos'
    set -l autosync_dir "$HOME/.gitx/autosync"
    set -l config_path "$autosync_dir/config"
    set -l lock_dir "$autosync_dir/lock"
    set -l lock_pid_path "$lock_dir/pid"
    set -l repos_dir "$HOME/.gitx/repos"

    if not test -f "$config_path"
        return 0
    end

    set -l current_platform (command uname)
    set -l default_backend launchd
    if test "$current_platform" = "Linux"
        set default_backend systemd-user
    end

    __gitx_autosync_load_config "$config_path" "$default_backend"
    or return 1

    if test "$__gitx_autosync_cfg_enabled" != "1"
        return 0
    end

    if test -d "$lock_dir"
        set -l lock_pid
        if test -f "$lock_pid_path"
            set lock_pid (string trim -- (command cat "$lock_pid_path" 2>/dev/null))
        end

        if test -n "$lock_pid"
            command kill -0 "$lock_pid" >/dev/null 2>/dev/null
            if test $status -eq 0
                return 0
            end
        end

        command rm -rf "$lock_dir" >/dev/null 2>/dev/null
        if test -d "$lock_dir"
            return 0
        end
    end

    command mkdir "$lock_dir" >/dev/null 2>/dev/null
    if test $status -ne 0
        return 0
    end

    command printf '%s\n' "$fish_pid" > "$lock_pid_path"
    if test $status -ne 0
        command rm -rf "$lock_dir" >/dev/null 2>/dev/null
        return 1
    end

    set -l repo_names
    if test "$__gitx_autosync_cfg_scope" = "all"
        if test -d "$repos_dir"
            for d in "$repos_dir"/*
                if test -d "$d/repo"
                    set repo_names $repo_names (basename "$d")
                end
            end
        end
    else if test -n "$__gitx_autosync_cfg_repos"
        set repo_names (string split ',' -- "$__gitx_autosync_cfg_repos")
    end

    set -l any_failure 0

    for repo_name in $repo_names
        if test -z "$repo_name"
            continue
        end

        set -l repo "$HOME/.gitx/repos/$repo_name/repo"
        if not test -d "$repo"
            set any_failure 1
            continue
        end

        gitx-commit "$repo_name"
        if test $status -ne 0
            set any_failure 1
            continue
        end

        set -l remote_url (command git --git-dir="$repo" --work-tree=/ config --get remote.origin.url 2>/dev/null)
        if test -z "$remote_url"
            continue
        end

        gitx "$repo_name" push
        if test $status -ne 0
            set any_failure 1
        end
    end

    command rm -rf "$lock_dir" >/dev/null 2>/dev/null

    if test $any_failure -eq 1
        return 1
    end

    return 0
end
