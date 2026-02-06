complete -c gitx-untrack -d 'Untrack file(s) and safely prune unused exclude entries'
complete -c gitx-untrack -l dry-run -d 'Show exact rm --cached and exclude changes'

function __gitx_untrack_needs_repo
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

complete -c gitx-untrack -n '__gitx_untrack_needs_repo' -f -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
