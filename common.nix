{
  pkgs,
  lib,
  config,
  ...
}: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    flake-registry = pkgs.writeText "registry.json" ''{"flakes":[],"version":2}'';
  };

  # Needed to build the flake.
  environment.systemPackages = [pkgs.git];
}
