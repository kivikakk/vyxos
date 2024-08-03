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
      ./git
      ./nix
      ./cowsay
    ]
    ++ optionals (hostData.server) [
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
