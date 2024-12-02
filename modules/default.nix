{
  config,
  lib,
  isDarwin,
  isServer,
  hostName,
  ...
}: let
  cfg = config.vyxos;
  inherit (lib) types mkOption mkMerge;
  inherit (lib) optionals optionalAttrs;
  hostData = (lib.importTOML ../hosts.toml).${hostName};
in {
  imports =
    [
      ./secrets
      ./fish
      ./nix
      ./cowsay
    ]
    ++ optionals (!isDarwin) [
      ./borg
    ]
    ++ optionals (!isDarwin && !hostData.server) [
      ./desktop
    ]
    ++ optionals (hostData.server) [
      ./fxsync
      ./nginx
      ./net
    ];

  options.vyxos =
    {
      vyxUser = mkOption {
        type = types.str;
        example = "kivikakk";
        default = hostData.user;
        readOnly = true;
      };
      vyxUserId = mkOption {
        type = types.int;
        example = 1000;
        default = hostData.uid or 1000;
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
        default = "Australia/Melbourne";
      };
      hostId = mkOption {
        type = types.str;
        default = hostData.hostId;
        readOnly = true;
      };
    };

  config = mkMerge [
    {
      networking.hostName = cfg.hostName;
    }
    (optionalAttrs (!isDarwin) {
      time.timeZone = cfg.timeZone;
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
          uid = cfg.vyxUserId;
          isNormalUser = true;
          hashedPassword = builtins.readFile ../private/secrets/hashedpassword-vyxuser;
          description = cfg.vyxUser;
          extraGroups = ["wheel"];
        };
      };
      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {PasswordAuthentication = false;};
      };
    })
  ];
}
