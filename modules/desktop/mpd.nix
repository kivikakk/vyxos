{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vyxos.desktop;
  inherit (config.vyxos) vyxUser;
  inherit (lib) mkIf;
in {
  config = mkIf (cfg.enable) {
    services.mpd = {
      enable = true;
      user = vyxUser;
      musicDirectory = "/home/${vyxUser}/m";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "pipewire"
        }
      '';
    };

    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${vyxUser}.uid}";
    };
  };
}
