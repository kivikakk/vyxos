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
    services.displayManager.ly = {
      enable = true;
      settings = {
        bigclock = "fa";
        clear_password = true;
      };
    };

    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration # pins a core to 100%
      elisa
      konsole
    ];

    environment.systemPackages = [pkgs.wl-clipboard];

    services.printing.enable = true;

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    users.users.${vyxUser}.extraGroups = ["networkmanager"];

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
