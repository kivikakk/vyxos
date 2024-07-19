{
  pkgs,
  lib,
  config,
  ...
}: {
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      git # Needed to build the flake.
      helix # doas vipw ...
      nmap
      ;
  };
}
