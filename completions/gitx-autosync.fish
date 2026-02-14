complete -c gitx-autosync -d 'Enable, disable, or check periodic gitx commit and push'

function __gitx_autosync_mode
    set -l words (commandline -opc)
    set -e words[1]

    set -l positional
    set -l expecting_value 0

    for w in $words
        if test $expecting_value -eq 1
            set expecting_value 0
            continue
        end

        switch $w
            case -e --every -r --repo
                set expecting_value 1
            case -n --dry-run
                continue
            case '-*'
                continue
            case '*'
                set positional $positional $w
        end
    end

    if test (count $positional) -gt 0
        printf "%s\n" "$positional[1]"
    end
end

function __gitx_autosync_no_mode
    set -l mode (__gitx_autosync_mode)
    if test -z "$mode"
        return 0
    end
    return 1
end

function __gitx_autosync_on_mode
    set -l mode (__gitx_autosync_mode)
    switch "$mode"
        case on true 1
            return 0
    end
    return 1
end

complete -c gitx-autosync -n '__gitx_autosync_no_mode' -f -a 'on true 1 off false 0 status' -d 'Autosync mode'

complete -c gitx-autosync -s n -l dry-run -d 'Preview what would happen without making changes'
complete -c gitx-autosync -s e -l every -x -n '__gitx_autosync_no_mode; or __gitx_autosync_on_mode' -a '15m 30m 1h 2h' -d 'Autosync interval'
complete -c gitx-autosync -s r -l repo -x -n '__gitx_autosync_no_mode; or __gitx_autosync_on_mode' -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
