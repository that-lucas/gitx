function gitx-init --description 'Initialize ~/.gitx/profiles/<profile>/repo as bare repo with ignore-all exclude'
    if test (count $argv) -lt 1
        echo "Usage: gitx-init [--dry-run] <profile> [remote-url]" >&2
        return 1
    end

    set -l dry_run 0
    set -l args
    for a in $argv
        if test "$a" = "--dry-run"
            set dry_run 1
        else
            set args $args $a
        end
    end

    if test (count $args) -lt 1
        echo "Usage: gitx-init [--dry-run] <profile> [remote-url]" >&2
        return 1
    end

    set -l profile $args[1]
    set -l remote_url
    if test (count $args) -ge 2
        set remote_url $args[2]
    end

    set -l base "$HOME/.gitx/profiles/$profile"
    set -l repo "$base/repo"
    set -l info_dir "$repo/info"
    set -l exclude "$repo/info/exclude"

    set -l dry_cmds
    set -l dry_exclude
    set -l dry_config
    set -l run_cmds
    set -l run_exclude
    set -l run_config

    set -l mkdir_repo_cmd mkdir -p "$repo"
    if test $dry_run -eq 1
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $mkdir_repo_cmd))
    else
        command $mkdir_repo_cmd
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $mkdir_repo_cmd))
    end

    if not test -f "$repo/HEAD"
        set -l init_cmd git init --bare "$repo"
        if test $dry_run -eq 1
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $init_cmd))
        else
            command $init_cmd
            or begin
                echo "gitx-init: failed to initialize bare repo: $repo" >&2
                return 1
            end
            set run_cmds $run_cmds (string join -- ' ' (string escape -- $init_cmd))
        end
    end

    set -l mkdir_info_cmd mkdir -p "$info_dir"
    if test $dry_run -eq 1
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $mkdir_info_cmd))
    else
        command $mkdir_info_cmd
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $mkdir_info_cmd))
    end

    set -l has_ignore_all 0
    if test -f "$exclude"
        if grep -Eq '^[[:space:]]*/\*[[:space:]]*$' "$exclude"
            set has_ignore_all 1
        end
    end

    if test $has_ignore_all -eq 0
        if test $dry_run -eq 1
            if test -f "$exclude"
                set dry_exclude $dry_exclude "append: $exclude"
            else
                set dry_exclude $dry_exclude "write: $exclude"
            end
            set dry_exclude $dry_exclude "# Ignore everything by default (work-tree is /)"
            set dry_exclude $dry_exclude "/*"
        else
            if test -f "$exclude"
                if test -s "$exclude"
                    printf "\n# Ignore everything by default (work-tree is /)\n/*\n" >> "$exclude"
                    set run_exclude $run_exclude "append: $exclude"
                else
                    printf "# Ignore everything by default (work-tree is /)\n/*\n" > "$exclude"
                    set run_exclude $run_exclude "write: $exclude"
                end
            else
                printf "# Ignore everything by default (work-tree is /)\n/*\n" > "$exclude"
                set run_exclude $run_exclude "write: $exclude"
            end
            set run_exclude $run_exclude "# Ignore everything by default (work-tree is /)"
            set run_exclude $run_exclude "/*"
        end
    end

    if test -n "$remote_url"
        set -l cfg_url_cmd git --git-dir="$repo" config remote.origin.url "$remote_url"
        set -l cfg_fetch_cmd git --git-dir="$repo" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

        if test $dry_run -eq 1
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $cfg_url_cmd))
            set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $cfg_fetch_cmd))
            set dry_config $dry_config "remote.origin.url = $remote_url"
            set dry_config $dry_config "remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*"
        else
            command $cfg_url_cmd
            or begin
                echo "gitx-init: failed to set remote.origin.url" >&2
                return 1
            end
            set run_cmds $run_cmds (string join -- ' ' (string escape -- $cfg_url_cmd))
            set run_config $run_config "remote.origin.url = $remote_url"

            command $cfg_fetch_cmd
            or begin
                echo "gitx-init: failed to set remote.origin.fetch" >&2
                return 1
            end
            set run_cmds $run_cmds (string join -- ' ' (string escape -- $cfg_fetch_cmd))
            set run_config $run_config "remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*"
        end
    end

    set -l cfg_status_cmd git --git-dir="$repo" config status.showUntrackedFiles no
    if test $dry_run -eq 1
        set dry_cmds $dry_cmds (string join -- ' ' (string escape -- $cfg_status_cmd))
        set dry_config $dry_config "status.showUntrackedFiles = no"
    else
        command $cfg_status_cmd
        or begin
            echo "gitx-init: failed to set status.showUntrackedFiles=no" >&2
            return 1
        end
        set run_cmds $run_cmds (string join -- ' ' (string escape -- $cfg_status_cmd))
        set run_config $run_config "status.showUntrackedFiles = no"
    end

    if test $dry_run -eq 1
        echo "Dry Run Plan: gitx-init $profile"
        echo
        __gitx_print_section "Would run commands" $dry_cmds
        __gitx_print_section "Would write/append exclude" $dry_exclude
        __gitx_print_section "Would set git config" $dry_config
        echo "Summary: commands="(count $dry_cmds)", exclude_changes="(count $dry_exclude)", config_entries="(count $dry_config)
        echo
        echo "  repo: $repo"
        echo "  exclude: $exclude"
        if test -n "$remote_url"
            echo "  remote: $remote_url"
        end
        return 0
    end

    echo "Init Result: gitx-init $profile"
    echo
    __gitx_print_section "Commands run" $run_cmds
    __gitx_print_section "Exclude updates" $run_exclude
    __gitx_print_section "Git config updates" $run_config
    echo "Summary: commands="(count $run_cmds)", exclude_changes="(count $run_exclude)", config_entries="(count $run_config)
    echo
    __gitx_print_section "Resolved paths" "repo: $repo" "exclude: $exclude"
    if test -n "$remote_url"
        __gitx_print_section "Remote" "$remote_url"
    end
end
