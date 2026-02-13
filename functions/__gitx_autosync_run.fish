function __gitx_autosync_run --description 'Run one autosync cycle for configured gitx repos'
    set -l autosync_dir "$HOME/.gitx/autosync"
    set -l config_path "$autosync_dir/config"
    set -l lock_dir "$autosync_dir/lock"
    set -l repos_dir "$HOME/.gitx/repos"

    if not test -f "$config_path"
        return 0
    end

    set -l cfg_enabled 0
    set -l cfg_scope all
    set -l cfg_repos

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
                    set cfg_enabled "$value"
                end
            case 'scope'
                if test "$value" = "all" -o "$value" = "selected"
                    set cfg_scope "$value"
                end
            case 'repos'
                set cfg_repos "$value"
        end
    end < "$config_path"

    if test "$cfg_enabled" != "1"
        return 0
    end

    command mkdir "$lock_dir" >/dev/null 2>/dev/null
    if test $status -ne 0
        return 0
    end

    set -l repo_names
    if test "$cfg_scope" = "all"
        if test -d "$repos_dir"
            for d in "$repos_dir"/*
                if test -d "$d/repo"
                    set repo_names $repo_names (basename "$d")
                end
            end
        end
    else if test -n "$cfg_repos"
        set repo_names (string split ',' -- "$cfg_repos")
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

        gitx-commit "$repo_name" >/dev/null 2>/dev/null
        if test $status -ne 0
            set any_failure 1
            continue
        end

        set -l remote_url (command git --git-dir="$repo" --work-tree=/ config --get remote.origin.url 2>/dev/null)
        if test -z "$remote_url"
            continue
        end

        gitx "$repo_name" push >/dev/null 2>/dev/null
        if test $status -ne 0
            set any_failure 1
        end
    end

    command rmdir "$lock_dir" >/dev/null 2>/dev/null

    if test $any_failure -eq 1
        return 1
    end

    return 0
end
