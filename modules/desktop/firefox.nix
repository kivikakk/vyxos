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
    };
  };
}
