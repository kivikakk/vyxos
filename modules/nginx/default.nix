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
    builtins.removeAttrs config ["publicLinks"]
    // {
      forceSSL = mkForce true;
      enableACME = mkForce true;

      extraConfig = ''
        ${config.extraConfig}
        include ${./badgateway.conf};
      '';
    };
in {
  options.vyxos.nginx = {
    enable = mkEnableOption "VyxOS nginx";

    vhosts = mkOption {
      type = types.attrsOf (types.submoduleWith {
        modules = [
          (import "${nixpkgs}/nixos/modules/services/web-servers/nginx/vhost-options.nix" {inherit config lib;})
          {
            options = {
              publicLinks = mkOption {
                type = types.attrsOf types.path;
                default = {};
              };
            };
          }
        ];
      });
      default = {};
    };

    publicLinks = mkOption {
      type = types.attrsOf types.path;
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    networking.firewall.allowedTCPPorts = [80 443];

    users.users = {
      www = {
        isNormalUser = true;
        home = "/home/www";
        group = "nginx";
        createHome = true;
        homeMode = "710";
        # XXX: not sure I ever want to ssh in as www?
        # openssh.authorizedKeys.keys = config.users.users.${config.vyxos.vyxUser}.openssh.authorizedKeys.keys;
      };

      nginx.extraGroups = ["acme"];
    };

    systemd.services.nginx.serviceConfig.ProtectHome = "read-only";

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.mapAttrs (lib.const processVhost) cfg.vhosts;
    };

    systemd.tmpfiles.rules = [
      "d /home/www/public 0755 www nginx"
    ];

    home-manager.users.www = {
      home.stateVersion = "23.11";

      home.file = mapAttrs' (k: v: nameValuePair "public/${k}" {source = v;}) (
        foldlAttrs
        (acc: _: v: acc // v.publicLinks or {})
        ({error = ./error;} // cfg.publicLinks)
        cfg.vhosts
      );
    };
  };
}
