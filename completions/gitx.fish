complete -c gitx -d 'Run git commands against a gitx repo or all of them at once'

function __gitx_needs_repo
    set -l words (commandline -opc)
    set -e words[1]

    if test (count $words) -eq 0
        return 0
    end

    if test (count $words) -eq 1
        set -l current (commandline -ct)
        if test -n "$current"
            return 0
        end
    end

    return 1
end

complete -c gitx -n '__gitx_needs_repo' -f -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
