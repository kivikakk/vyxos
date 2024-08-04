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

    services.xserver.xkb = {
      layout = "us";
      variant = "dvorak";
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

    users.users.${vyxUser}.extraGroups = ["networkmanager" "dialout"];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password-cli"
        "1password"
        "discord"
      ];

    programs = {
      firefox = {
        enable = true;
        # For SearchEngines: https://mozilla.github.io/policy-templates/#searchengines-this-policy-is-only-available-on-the-esr
        package = pkgs.firefox-esr;
        policies = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisableMasterPasswordCreation = true;
          DisablePocket = true;
          DisableProfileImport = true;
          DisableProfileRefresh = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = false;
            MoreFromMozilla = false;
          };
          ExtensionSettings = {
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            };
            "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/linkding-extension/latest.xpi";
            };
            "uBlock0@raymondhill.net" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
          };
          SearchEngines = {
            Add = [
              {
                Name = "Comenzar";
                URLTemplate = "http://localhost:9292/?q={searchTerms}";
                Method = "GET";
                Alias = "comenzar";
              }
            ];
            Default = "Comenzar";
          };
        };
      };

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
      ];

      home.file = {
        ".config/dosbox-x/dosbox-x-2024.07.01.conf".source = ./dosbox-x.conf;
        ".config/kuriikwsfilterrc".source = ./kuriikwsfilterrc;
        ".local/share/kf6/searchproviders/comenzar.desktop".source = ./comenzar.desktop;
      };

      # qdbus org.kde.krunner /App org.kde.krunner.App.displaySingleRunner krunner_webshortcuts

      programs.kitty = {
        enable = true;
        theme = "Catppuccin-Mocha";
        font.name = "Iosevka Term Slab";
      };
    };
  };
}
