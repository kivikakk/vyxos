{
  config,
  lib,
  isDarwin,
  ...
}: let
  cfg = config.vyxos.secrets;
  inherit (config.vyxos) vyxUser hostName;
  inherit (lib) types mkIf mkMerge mkDefault mkOption optionalAttrs;
  inherit (lib) pathExists foldlAttrs elemAt readFile mapAttrs;
  inherit (lib) filterAttrs attrVals flip assertMsg;

  keys = let
    sources = builtins.readDir ../../sources;
    filtered =
      foldlAttrs
      (
        acc: n: v: let
          match = builtins.match "(.+-.+)-id_ed25519\\.pub" n;
        in
          acc
          // (
            if match != null && v == "regular"
            then {${elemAt match 0} = readFile ../../sources/${n};}
            else {}
          )
      )
      {}
      sources;
  in
    filtered;
in {
  options.vyxos.secrets = {
    baseAuthorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "kivikakk-seraphim"
        "kivikakk-piret"
      ];
      description = "Base keys in ~/.ssh/authorized_keys.";
      apply = flip attrVals keys;
    };

    additionalAuthorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["kivikakk-celica"];
      description = ''
        Additional keys for ~/.ssh/authorized_keys. Separate from baseAuthorizedKeys
        to make overriding a bit easier.
      '';
      apply = flip attrVals keys;
    };

    encrypted = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          mode = mkOption {
            type = types.str;
            default = "0400";
          };
          owner = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          group = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          path = mkOption {
            type = types.nullOr types.path;
            default = null;
          };
        };
      });
      default = {};
      description = ''
        Secrets that should be decrypted.  Specifying "path" is mandatory
        on macOS since otherwise they just get thrown in a random tempdir
        without an obvious way to find them.
      '';
    };

    decrypted = mkOption {
      readOnly = true;
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.path;
            readOnly = true;
          };
        };
      });
      description = ''
        Contains paths of decrypted secrets specified in vyxos.secrets.encrypted.
      '';
    };
  };

  config = let
    sopsBaseConfig = {
      defaultSopsFormat = "binary";
      age =
        {
          sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
          generateKey = false;
        }
        // optionalAttrs isDarwin {
          keyFile = "/Users/${vyxUser}/Library/Application Support/sops/age/keys.txt";
        };
    };
    sopsBaseSecrets = {
      "${vyxUser}-id_ed25519" =
        if isDarwin
        then {
          path = "/Users/${vyxUser}/.ssh/id_ed25519";
        }
        else {
          path = "/home/${vyxUser}/.ssh/id_ed25519";
          owner = vyxUser;
          group = config.users.users.${vyxUser}.group;
        };
    };
    mkSopsSecret = name: def: let
      globalCandidate = ../../private/secrets/${name};
      localCandidate = ../../private/secrets/${hostName}/${name};
      assertion = pathExists globalCandidate -> !pathExists localCandidate;
    in
      assert assertMsg assertion "a secret ${name} exists at both global and ${hostName}-specific levels";
        {
          sopsFile =
            if pathExists globalCandidate
            then globalCandidate
            else localCandidate;
          format = "binary";
          mode = "0400";
        }
        // (filterAttrs (_: v: v != null) def);
    sopsConfig = mkMerge [
      sopsBaseConfig
      {
        secrets = mapAttrs mkSopsSecret (sopsBaseSecrets // cfg.encrypted);
      }
    ];
  in
    mkMerge [
      (optionalAttrs isDarwin {
        home-manager.users.${vyxUser}.sops = sopsConfig;
        vyxos.secrets.decrypted = mapAttrs (k: _: {path = config.home-manager.users.${vyxUser}.sops.secrets.${k}.path;}) cfg.encrypted;
      })
      (optionalAttrs (!isDarwin) {
        sops = sopsConfig;
        vyxos.secrets.decrypted = mapAttrs (k: _: {path = config.sops.secrets.${k}.path;}) cfg.encrypted;
      })

      {
        users.users.${vyxUser} = {
          openssh.authorizedKeys.keys = cfg.baseAuthorizedKeys ++ cfg.additionalAuthorizedKeys;
        };

        home-manager.users.${vyxUser} = {
          home.file.".ssh/id_ed25519.pub".source = ../../sources/${vyxUser}-${hostName}-id_ed25519.pub;
        };
      }
    ];
}
