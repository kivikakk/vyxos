{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vyxos.borg;
  inherit (lib) mkIf mkEnableOption;
in {
  options.vyxos.borg = {
    enable = mkEnableOption "VyxOS Borg";
  };

  config = mkIf (cfg.enable) (let
    repo = "kivikakk@siiludus.lan:/volume1/piret varukoopia/piret";
  in {
    vyxos.secrets.encrypted = {
      "borg-passphrase" = {};
      "borg-ssh-key" = {};
    };

    environment.systemPackages = [pkgs.borgbackup];

    services = {
      borgbackup.jobs = {
        piret-siiludus = {
          paths = ["/"];
          exclude = ["/nix" "/dev" "/proc" "/tmp" "/run" "/boot" "/sys" "sh:**/.cache"];
          inherit repo;
          encryption = {
            mode = "repokey-blake2";
            passCommand = "cat ${config.vyxos.secrets.decrypted."borg-passphrase".path}";
          };
          environment = {
            BORG_RSH = "ssh -i ${config.vyxos.secrets.decrypted."borg-ssh-key".path}";
          };
          doInit = false;
          compression = "auto,lzma";
          startAt = "*-*-* 10/4:25:00"; # Every 4 hours, starting 10:25:00.
          prune.keep = {
            within = "1d";
            daily = 7;
            weekly = 4;
            monthly = -1;
          };
          # See https://github.com/NixOS/nixpkgs/issues/323262 and https://github.com/NixOS/nixpkgs/pull/332319.
          extraArgs = "--remote-path=/usr/local/bin/borg";
          # From: https://github.com/NixOS/nixpkgs/issues/177733#issuecomment-1200499837
          preHook = ''
            realBorg="$(${pkgs.which}/bin/which borg)"

            borg() {
              returnCode=0
              systemd-inhibit "$realBorg" "$@" || returnCode=$?

              if [[ $returnCode -eq 1 ]]; then
                return 0
              else
                return $returnCode
              fi
            }
          '';
        };
      };

      postgresql.package = pkgs.postgresql_14;
    };

    home-manager.users.${config.vyxos.vyxUser} = {
      programs = {
        fish.shellAliases = {
          vborg = ''
            doas env \
              BORG_REPO="${repo}" \
              BORG_PASSCOMMAND="cat /run/secrets/borg-passphrase" \
              BORG_RSH="ssh -i /run/secrets/borg-ssh-key" \
              borg --remote-path=/usr/local/bin/borg'';
        };
      };
    };
  });
}
