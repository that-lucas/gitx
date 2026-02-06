complete -c gitx-commit -d 'Commit staged changes (default message: local date/time)'
complete -c gitx-commit -s n -l dry-run -d 'Show exact commit command and staged files'
complete -c gitx-commit -s m -l message -r -d 'Commit message'

function __gitx_commit_needs_repo
    set -l words (commandline -opc)
    set -e words[1]

    set -l positional
    set -l expecting_message 0

    for w in $words
        if test $expecting_message -eq 1
            set expecting_message 0
            continue
        end

        switch $w
            case -m --message
                set expecting_message 1
                continue
            case -n --dry-run
                continue
            case '-*'
                continue
            case '*'
                set positional $positional $w
        end
    end

    # If message option was provided but its value isn't complete yet,
    # do not suggest repo names.
    if test $expecting_message -eq 1
        return 1
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

complete -c gitx-commit -n '__gitx_commit_needs_repo' -f -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
