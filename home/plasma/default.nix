{config, ...}: {
  programs.plasma = {
    enable = true;

    # TODO: describe more here.
    # https://nix-community.github.io/plasma-manager/options.xhtml

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    # Add comenzar search provider.
    dataFile = {
      "kf6/searchproviders/comenzar.desktop" = {
        "Desktop Entry" = {
          Charset = "";
          Hidden = false;
          Keys = "comenzar";
          Name = "Comenzar";
          Query = "http://localhost:9292/?q=\\{@}";
          Type = "Service";
        };
      };
    };

    # Enable web shortcuts, set comenzar as default.
    configFile = {
      kuriikwsfilterrc = {
        General = {
          DefaultWebShortcut = "comenzar";
          EnableWebShortcuts = true;
          KeywordDelimiter = ":";
          PreferredWebShortcuts = "";
          UsePreferredWebShortcutsOnly = false;
        };
      };
    };

    # Launch webshortcuts single runner; will use comenzar.
    hotkeys.commands."launch-krunner-comenzar" = {
      name = "Launch KRunner for Comenzar searches";
      key = "Alt+Shift+Space";
      command = "qdbus org.kde.krunner /App org.kde.krunner.App.displaySingleRunner krunner_webshortcuts";
    };
  };
}
