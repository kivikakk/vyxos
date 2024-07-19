{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./home/fish.nix
    ./home/ssh.nix
    ./home/helix.nix
    ./home/tmux.nix
    ./home/git.nix
    ./home/ripgrep.nix
  ];

  home = {
    stateVersion = "23.05";

    packages = with pkgs; ([
        # Tools provided by or useful with the config.
        vyxos-git
        cowsay # :|3
        age
        sops
        ssh-to-age
        nix-tree
      ]
      ++ [
        # Generally helpful.
        dig
        file
        htop
        httpie
        inetutils
        jq
        lsof
        tio
        unixtools.xxd
        unzip
        wget
        # binutils # Do Not. This messes up things on macOS.
      ]
      ++ [
        # Things I keep meaning to learn to use properly.
        fd
        fx
      ]);
  };
}
