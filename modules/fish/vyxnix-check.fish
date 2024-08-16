function check_
    set -f cmd $argv[1]
    set -e argv[1]

    set -g out (string split ' ' (vyxnix $cmd --vyx-dry-run --vyx-no-defaults $argv))
end

function assert
    set -f cmd $argv[1]
    set -e argv[1]

    if test $out[1] != nix
        exit 1
    else if test $out[2] != "$cmd"
        exit 2
    end

    set -e out[1]
    set -e out[1]

    while count $out >/dev/null
        set out[1] (string unescape -- "$out[1]")
        if test "$out[1]" != "$argv[1]"
            echo mismatch: "$out[1]" != "$argv[1]"
            exit 3
        end
        set -e out[1]
        set -e argv[1]
    end

    if count $argv >/dev/null
        exit 4
    end
end

check_ run . -- build
assert run . -- build

check_ shell helix vim
assert shell nixpkgs#helix nixpkgs#vim --command fish

check_ shell helix vim -- make
assert shell nixpkgs#helix nixpkgs#vim --command fish -c make

# TODO: be able to check quoted args.
