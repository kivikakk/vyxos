function vyxnix -d "vyxos nix3 launcher"
    # Principal nix3 launcher.
    #
    # "develop" and "shell" are treated specially:
    # vyxnix develop                  -> nix develop --command fish
    # vyxnix develop x y z            -> nix develop x y z --command fish
    # vyxnix develop x -- y z         -> nix develop x --command fish -c "y z"
    # vyxnix develop x --command y z  -> nix develop x --command y z
    # "d/s" below refers to these cases.
    #
    # "run" and "shell" are also treated specially:
    # vyxnix run xyz                  -> nix run nixpkgs#xyz
    # vyxnix run abc#def              -> nix run abc#def
    # vyxnix shell uvw -- nyonk       -> nix shell nixpkgs#uvw -- nyonk
    #
    # !x=y translates to --override-input x y.
    # Default options (specify --vyx-no-defaults to omit):
    set -f defaultargs -L --keep-going

    # Specify --vyx-dry-run to echo the command that would be executed.

    # $state: "args", "command", "run"
    #  - "args" is the initial state.
    #  - (d/s only) "command" is entered when "--command" is encountered.
    #               All remaining arguments are appended to $args.
    #  - (d/s only) "run" is entered when "--" is encountered.
    #               All remaining arguments are appended to $run.
    set -f state args

    # $args: arguments passed to the command, not including any 'run'.
    set -f args

    # $run: run arguments, passed to the command (fish).
    set -f run

    # $command: the nix3 subcommand to run.
    set -f command $argv[1]
    set -e argv[1]

    # $ds: 1 if develop or shell, 0 otherwise.
    if test "$command" = develop -o "$command" = shell
        set -f ds 1
    else
        set -f ds 0
    end

    # $nix: ["nix"] normally, ["echo" "nix"] if we're doing a dry run
    set -f nix nix

    for arg in $argv
        switch $state
            case args
                if test "$arg" = --vyx-no-defaults
                    set defaultargs
                    continue
                end

                if test "$arg" = --vyx-dry-run
                    set -p nix echo
                    continue
                end

                if string match -qr '\A!(?<input>[^=]+)=(?<override>.+)\z' -- "$arg"
                    set -a args --override-input "$input" "$override"
                    continue
                end

                if test "$arg" = --command -a "$ds" -eq 1
                    set -a args --command
                    set state command
                else if test "$arg" = -- -a "$ds" -eq 1
                    set state run
                else if test "$command" = run -o "$command" = shell
                    if string match -qr '#' -- "$arg"
                        # nr abc#def ...
                        # ns abc#def ...
                        set -a args $arg
                        set state command
                    else if string match -qr '\A-' -- "$arg"
                        # nr --xyz ...
                        # ns --xyz ...
                        set -a args $arg
                    else if string match -qr ':' -- "$arg"
                        # nr github:xyz/abc ...
                        set -a args $arg
                    else
                        # nr abc ...
                        # ns abc ...
                        set -a args "nixpkgs#$arg"
                        set state command
                    end
                else
                    set -a args $arg
                end

            case command
                set -a args $arg

            case run
                set -a run $arg
        end
    end

    if test "$state" = run
        $nix $command $defaultargs $args --command fish -c (string escape -- $run | string join ' ')
    else
        if test "$state" = args -a "$ds" -eq 1
            set -a args --command fish
        end

        $nix $command $defaultargs $args
    end
end

complete -c vyxnix -l vyx-no-defaults -d "omit the default arguments passed by vyxnix"
complete -c vyxnix -l vyx-dry-run -d "do a dry run of this command; i.e. echo what would be run"
complete -c vyxnix -w nix
