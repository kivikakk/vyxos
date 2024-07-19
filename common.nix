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

  # Needed to build the flake.
  environment.systemPackages = [pkgs.git];
}
