complete -c gitx-track -d 'Add files to a gitx repo so they start being tracked'
complete -c gitx-track -l dry-run -d 'Preview which files would be tracked'

function __gitx_track_needs_repo
    set -l words (commandline -opc)
    set -e words[1]

    set -l positional
    for w in $words
        switch $w
            case --dry-run
                continue
            case '-*'
                continue
            case '*'
                set positional $positional $w
        end
    end

    if test (count $positional) -eq 0
        return 0
    end

    if test (count $positional) -eq 1
        set -l current (commandline -ct)
        if test -n "$current"
            return 0
        end
    end

    return 1
end

# First positional argument: repo name from ~/.gitx/repos
complete -c gitx-track -n '__gitx_track_needs_repo' -f -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
