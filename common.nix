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
    ];
  };

  # Needed to build the flake.
  environment.systemPackages = [pkgs.git];
}
