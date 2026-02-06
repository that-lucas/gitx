complete -c gitx -d 'Run git with --git-dir ~/.gitx/profiles/<profile>/repo and --work-tree=/'

function __gitx_needs_profile
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

complete -c gitx -n '__gitx_needs_profile' -f -a '(for d in ~/.gitx/profiles/*; test -d "$d"; and basename "$d"; end)' -d 'Profile name'
