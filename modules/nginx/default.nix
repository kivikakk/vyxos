{
  nixpkgs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vyxos.nginx;
  inherit (lib) types mkEnableOption mkOption mkIf mkForce;
  inherit (lib) optionalString mapAttrs' nameValuePair foldlAttrs;

  processVhost = config:
    config
    // {
      forceSSL = mkForce true;
      enableACME = mkForce true;

      extraConfig = ''
        ${config.extraConfig}

        error_page 502 /502.html;
        location = /502.html {
          root ${./error};
        }
        location = /badgateway.jpg {
          root ${./error};
        }
      '';
    };
in {
  options.vyxos.nginx = {
    enable = mkEnableOption "VyxOS nginx";

    vhosts = mkOption {
      type = types.attrsOf (types.submoduleWith {
        modules = [
          (import "${nixpkgs}/nixos/modules/services/web-servers/nginx/vhost-options.nix" {inherit config lib;})
        ];
      });
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    networking.firewall.allowedTCPPorts = [80 443];

    users.users = {
      nginx.extraGroups = ["acme"];
    };

    # Needed for reading sites from /home/kinu.
    systemd.services.nginx.serviceConfig.ProtectHome = "read-only";

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.mapAttrs (lib.const processVhost) cfg.vhosts;
    };
  };
}
