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

    sessionVariables = {
      EDITOR = "hx";
    };

    packages = with pkgs; [
      vyxos-git
      age
      wget
      nix-tree
      # binutils # Do Not. This messes up things on macOS.
      unzip
      inetutils
      htop
      clang-tools_16 # for clang-format
      file
      dig
      lsof
      fx # JSON viewer
      jq
      docutils # python
      bundix # ruby
      tio
      fd
      cowsay
      ssh-to-age
      sops
      unixtools.xxd
      httpie
    ];
  };
}
