{
  config,
  lib,
  pkgs,
  isDarwin,
  hostName,
  ...
}: let
  cfg = config.vyxos;
  inherit (lib) types mkDefault mkOption mkMerge mkIf;
  inherit (lib) optionals optionalAttrs;
  inherit (lib) splitString elemAt id toInt;
  hostData = (lib.importTOML ../hosts.toml).${hostName};

  splitting = attrs: key: delim: index: parse:
    if attrs ? ${key}
    then let
      parts = splitString delim attrs.${key};
      part = elemAt parts index;
    in
      parse part
    else null;
in {
  imports =
    [
      ./secrets
      ./fish
      ./git
      ./nix
      ./cowsay
    ]
    ++ optionals (!isDarwin) [
      ./nginx
    ];

  options.vyxos =
    {
      vyxUser = mkOption {
        type = types.str;
        example = "kivikakk";
        default = hostData.user;
        readOnly = true;
      };
      hostName = mkOption {
        type = types.str;
        example = "exampleHost";
        default = hostName;
        readOnly = true;
      };
      isServer = mkOption {
        type = types.bool;
        default = hostData.server;
        readOnly = true;
      };
    }
    // optionalAttrs (!isDarwin) {
      timeZone = mkOption {
        type = types.str;
        default = "Europe/Tallinn";
      };
      hostId = mkOption {
        type = types.str;
        default = hostData.hostId;
        readOnly = true;
      };
      # TODO: move this all into networking/.
      net = mkOption {
        readOnly = true;
        type = types.submodule {
          options = {
            dev = mkOption {
              type = types.str;
              example = "eno1";
              readOnly = true;
            };
            ipv4a = mkOption {
              type = types.nullOr types.str;
              example = "64.71.162.164";
              readOnly = true;
            };
            ipv4p = mkOption {
              type = types.nullOr (types.ints.between 8 32);
              example = 26;
              readOnly = true;
            };
            gwv4a = mkOption {
              type = types.nullOr types.str;
              example = "172.31.1.1";
              readOnly = true;
            };
            gwv4p = mkOption {
              type = types.nullOr (types.ints.between 8 32);
              example = 32;
              readOnly = true;
            };
            ipv6a = mkOption {
              type = types.nullOr types.str;
              example = "2402:1f00:8201:3e3:49::2";
              readOnly = true;
            };
            ipv6p = mkOption {
              type = types.nullOr (types.ints.between 16 128);
              example = 64;
              readOnly = true;
            };
            gwv6a = mkOption {
              type = types.nullOr types.str;
              example = "2402:1f00:8201:3ff:ff:ff:ff:ff";
              readOnly = true;
            };
            gwv6i = mkOption {
              type = types.nullOr types.str;
              example = "eno1";
              readOnly = true;
            };
          };
        };
        default = {
          dev = hostData.net.dev;
          ipv4a = splitting hostData.net "ipv4" "/" 0 id;
          ipv4p = splitting hostData.net "ipv4" "/" 1 toInt;
          gwv4a = splitting hostData.net "gwv4" "/" 0 id;
          gwv4p = splitting hostData.net "gwv4" "/" 1 toInt;
          ipv6a = splitting hostData.net "ipv6" "/" 0 id;
          ipv6p = splitting hostData.net "ipv6" "/" 1 toInt;
          gwv6a = splitting hostData.net "gwv6" "#" 0 id;
          gwv6i = splitting hostData.net "gwv6" "#" 1 id;
        };
      };
    };

  config = mkMerge [
    {
      networking.hostName = cfg.hostName;
    }
    (optionalAttrs (!isDarwin) {
      time.timeZone = cfg.timeZone;
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = "1"; # for tailscale exit node
        "net.ipv6.conf.all.forwarding" = "1"; # for tailscale exit node
      };
      networking = mkMerge [
        {
          inherit (cfg) hostId;
          nameservers = ["1.1.1.1" "1.0.0.1"];
          firewall = {
            enable = mkDefault true;
            allowedTCPPorts = [22];
            allowedUDPPorts = [config.services.tailscale.port];
            trustedInterfaces = ["tailscale0"];
          };
        }
        (mkIf (cfg.net.ipv4a != null) {
          useDHCP = false;
          networkmanager.enable = false;
          interfaces.${cfg.net.dev}.ipv4 = {
            addresses = [
              {
                address = cfg.net.ipv4a;
                prefixLength = cfg.net.ipv4p;
              }
            ];
            routes = [
              {
                address = cfg.net.gwv4a;
                prefixLength = cfg.net.gwv4p;
              }
            ];
          };
          defaultGateway = cfg.net.gwv4a;
        })
        (mkIf (cfg.net.ipv6a != null) {
          useDHCP = false;
          networkmanager.enable = false;
          interfaces.${cfg.net.dev}.ipv6.addresses = [
            {
              address = cfg.net.ipv6a;
              prefixLength = cfg.net.ipv6p;
            }
          ];
          defaultGateway6 = {
            address = cfg.net.gwv6a;
            interface = cfg.net.gwv6i;
          };
        })
      ];
      systemd.services.vyxos-transport-layer-offloads = {
        # See https://tailscale.com/kb/1320/performance-best-practices#ethtool-configuration.
        description = "VyxOS: better performance for exit nodes";
        after = ["network.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.ethtool}/sbin/ethtool -K ${cfg.net.dev} rx-udp-gro-forwarding on rx-gro-list off";
        };
        wantedBy = ["default.target"];
      };
      security = {
        doas = {
          enable = true;
          extraRules = [
            {
              groups = ["wheel"];
              noPass = true;
              keepEnv = true;
            }
          ];
        };
        acme = {
          acceptTerms = true;
          defaults = {email = "ashe@kivikakk.ee";};
        };
      };
      users.users = {
        root = {
          initialHashedPassword = builtins.readFile ../private/secrets/hashedpassword-root;
        };
        ${cfg.vyxUser} = {
          isNormalUser = true;
          initialHashedPassword = builtins.readFile ../private/secrets/hashedpassword-vyxuser;
          description = cfg.vyxUser;
          extraGroups = ["wheel"];
        };
      };
      services.openssh = {
        enable = true;
        settings = {PasswordAuthentication = false;};
      };
    })
  ];
}
