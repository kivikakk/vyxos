{
  config,
  pkgs,
  lib,
  isServer,
  isDarwin,
  ...
}: {
  imports =
    [
      ./home/fish.nix
      ./home/ssh.nix
      ./home/helix.nix
      ./home/tmux.nix
      ./home/git.nix
      ./home/ripgrep.nix
      ./home/aerc.nix
      ./home/jujutsu.nix
    ]
    ++ lib.optionals (!isServer && !isDarwin) [
      ./home/plasma
    ];

  home = {
    stateVersion = "23.05";

    sessionVariables.RUST_BACKTRACE = "full";

    packages = with pkgs; ([
        # Tools provided by or useful with the config.
        git
        cowsay # :|3
        age
        sops
        ssh-to-age
        nix-tree
        pandoc # aerc
        eza
      ]
      ++ [
        # Generally helpful.
        _7zz
        dig
        entr
        file
        htop
        xh # replacing HTTPie
        inetutils
        jq
        lsof
        tio
        unixtools.xxd
        unzip
        wget
        # binutils # Do Not. This messes up things on macOS.
        fd
      ]);
  };
}
