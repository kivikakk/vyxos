{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: let
  inherit (config.vyxos) vyxUser;
  inherit (lib) mkIf optionalAttrs mkMerge;

  common = ''
    # modules/ghostty/default.nix
    working-directory = ${config.users.users.${config.vyxos.vyxUser}.home}/g

    # ./config.common
    ${builtins.readFile ./config.common}
  '';
in {
  config = mkMerge [
    (optionalAttrs (!isDarwin) {
      home-manager.users.${vyxUser} = {
        home.packages = [pkgs.ghostty];

        home.file.".config/ghostty/config".source =
          pkgs.writeText "ghostty-config"
          ''
            ${common}

            # !isDarwin
            font-size = 12
            background-opacity = 0.95
          '';
      };
    })
    (optionalAttrs isDarwin {
      home-manager.users.${vyxUser} = {
        home.file."Library/Application Support/com.mitchellh.ghostty/config".source =
          pkgs.writeText "ghostty-config"
          ''
            ${common}

            # isDarwin
            font-size = 14
            background-opacity = 0.9
            background-blur-radius = 10

            macos-option-as-alt = left
          '';
      };

      # Hack: https://github.com/ghostty-org/ghostty/discussions/2832
      environment.variables.XDG_DATA_DIRS = ["$GHOSTTY_SHELL_INTEGRATION_XDG_DIR"];
    })
  ];
}
