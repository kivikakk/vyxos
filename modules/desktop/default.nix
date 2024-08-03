{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vyxos.desktop;
  inherit (config.vyxos) vyxUser;
  inherit (lib) mkIf mkEnableOption;
in {
  options.vyxos.desktop = {
    enable = mkEnableOption "VyxOS desktop";
  };

  config = mkIf (cfg.enable) {
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "et_EE.UTF-8";
      LC_IDENTIFICATION = "et_EE.UTF-8";
      LC_MEASUREMENT = "et_EE.UTF-8";
      LC_MONETARY = "et_EE.UTF-8";
      LC_NAME = "et_EE.UTF-8";
      LC_NUMERIC = "et_EE.UTF-8";
      LC_PAPER = "et_EE.UTF-8";
      LC_TELEPHONE = "et_EE.UTF-8";
      LC_TIME = "et_EE.UTF-8";
    };

    services.xserver.enable = true;

    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver = {
      layout = "us";
      xkbVariant = "dvorak";
    };
    console.keyMap = "dvorak";

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

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password-cli"
        "1password"
      ];

    programs = {
      firefox.enable = true;

      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [vyxUser];
      };
    };

    environment.systemPackages = with pkgs; [
      iosevka
    ];
  };
}
