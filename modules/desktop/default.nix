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
  imports = [
    ./gui.nix
    ./mpd.nix
    ./firefox.nix
  ];

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

    users.users.${vyxUser}.extraGroups = ["dialout"];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password-cli"
        "1password"
        "discord"
        "obsidian"
      ];

    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [vyxUser];
      };
    };

    fonts.packages = with pkgs; [
      (iosevka.override {
        set = "TermSlab";
        privateBuildPlan = {
          family = "Iosevka Term Slab";
          spacing = "term";
          serifs = "slab";
          noCvSs = false;
          exportGlyphNames = true;

          widths = {
            Condensed = {
              shape = 500;
              menu = 3;
              css = "condensed";
            };
            Normal = {
              shape = 600;
              menu = 5;
              css = "normal";
            };
          };
        };
      })
    ];

    home-manager.users.${vyxUser} = {
      home.packages = with pkgs; [
        discord
        dosbox-x
        obsidian
        element-desktop
      ];

      home.file = {
        ".config/dosbox-x/dosbox-x-2024.07.01.conf".source = ./dosbox-x.conf;
      };

      programs.kitty = {
        enable = true;
        theme = "Catppuccin-Mocha";
        font.name = "Iosevka Term Slab";
      };

      programs.ncmpcpp = {
        enable = true;
      };
    };
  };
}
