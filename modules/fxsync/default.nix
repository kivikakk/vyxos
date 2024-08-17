{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vyxos.fxsync;
  inherit (lib) mkIf mkEnableOption;
in {
  options.vyxos.fxsync = {
    enable = mkEnableOption "VyxOS Firefox sync server";
  };

  config = mkIf (cfg.enable) {
    vyxos.secrets.encrypted = {
      "fxsync-secrets" = {};
    };

    services = {
      mysql.package = pkgs.mariadb;

      firefox-syncserver = rec {
        enable = true;
        secrets = config.vyxos.secrets.decrypted."fxsync-secrets".path;
        singleNode = {
          enable = true;
          enableNginx = true;
          hostname = "fxsync.hrzn.ee";
        };
        settings.port = 6505;
      };
    };
  };
}
