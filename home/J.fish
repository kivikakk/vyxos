function J -d "jujutsu launcher"
    # !i -> --ignore-immutable
    # !b -> --allow-backwards
    # !p -> --no-pager
    # !ae -> --reset-author --no-edit
    #
    # TODO: unify with vyxnix somehow?

    # Specify --vyx-dry-run to echo the command that would be executed.
    set -f dryrun 0

    # $args: arguments passed to the command
    set -f args

    for arg in $argv
        if test "$arg" = --vyx-dry-run
            set dryrun 1
            continue
        end

        if test "$arg" = "!i"
            set -a args --ignore-immutable
            continue
        end

        if test "$arg" = "!b"
            set -a args --allow-backwards
            continue
        end

        if test "$arg" = "!p"
            set -a args --no-pager
            continue
        end

        if test "$arg" = "!ae"
            set -a args --reset-author --no-edit
            continue
        end

        set -a args $arg
    end

    if test "$dryrun" -eq 1
        echo command jj (string escape -- $args)
    else
        command jj $args
    end
end

complete -c J -l vyx-dry-run -d "do a dry run of this command; i.e. echo what would be run"
complete -c J -w jj
