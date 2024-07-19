{
  config,
  lib,
  ...
}: let
  cfg = config.vyxos.nix;
  inherit (lib) types mkIf mkOption;
in {
  options.vyxos.nix = {
    extraDependencies = mkOption {
      description = "Extra derivations to build & include in the system closure that are otherwise unreferenced.";
      type = types.listOf types.path;
      default = [];
    };
  };

  config.environment.etc."nix/extra-dependencies.list" = {
    text = toString cfg.extraDependencies;
  };
}
