function ZZZ -d "multi-host rebuilder"
    # Multi-host Nix rebuilder.

    # Force a rebuild on targets even if a new version wasn't pulled.
    set -f force 0
    if test "$argv[1]" = -f
        set -f force 1
        set -e argv[1]
    end

    # The hosts we're connecting to. These should be acceptable for ssh.
    set -f hosts $argv

    # Spawn a tmux session, create panes for each target host.
    set -f state init
    for host in $hosts
        set -l CMD \
            -e HOST="$host" '
            echo starting
            echo target: $HOST
            source $VYXOS/modules/fish/ZZZ.fish
            begin
              functions ZZZe
              echo ZZZe '"$force"'
            end | ssh -T $HOST'

        switch "$state"
            case init
                tmux -L ZZZ new-session -d -x - -y - $CMD
                tmux -L ZZZ set-option -g remain-on-exit failed
                set state next
            case next
                tmux -L ZZZ split-window $CMD 2>/dev/null
                if test "$status" -ne 0
                    # Probably "no space for new pane".
                    tmux -L ZZZ select-layout tiled
                    tmux -L ZZZ new-window $CMD
                end
        end
    end

    tmux -L ZZZ select-layout tiled
    tmux -L ZZZ bind-key -n Escape kill-window

    tmux -L ZZZ attach-session
end

function ZZZe
    set -f force "$argv[1]"

    function ZZZe_fail
        echo "exiting: "(hostname) 1>&2
        exit "$argv[1]"
    end

    cd $VYXOS || ZZZe_fail 10
    git config remote.origin.url git@github.com:kivikakk/vyxos || ZZZe_fail 11
    set before (git rev-parse HEAD)
    git pull || ZZZe_fail 12
    set after (git rev-parse HEAD)
    echo "before:" "$before" "after:" "$after"
    if test "$force" -eq 0 -a "$before" = "$after"
        exit 0
    end

    ./rebuild switch || ZZZe_fail 13
end
