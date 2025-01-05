{
  nixpkgs,
  system,
  hostName,
}: {
  root = {
    system.stateVersion = 4;
  };

  module = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      ./seraphim-r.nix
      ./seraphim-purge-bunny.nix
    ];

    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    vyxos.secrets = {
      additionalAuthorizedKeys = [
        "kivikakk-celica"
        "kivikakk-estrellita"
      ];
      encrypted = {
        "aerc-password" = {};
        "charlottia-id_ed25519" = {
          path = "/Users/${config.vyxos.vyxUser}/.ssh/charlottia-id_ed25519";
        };
      };
    };

    users = {
      users = {
        ${config.vyxos.vyxUser} = {
          uid = 501;
          gid = 20;
          home = "/Users/${config.vyxos.vyxUser}";
          description = "Asherah Connor";
        };
      };
    };

    home-manager.users.${config.vyxos.vyxUser} = {
      accounts.email.accounts.asherah.passwordCommand = "cat ${config.vyxos.secrets.decrypted."aerc-password".path}";

      home.file.".ssh/charlottia-id_ed25519.pub".source = ../sources/charlottia-id_ed25519.pub;

      home.packages = with pkgs; [
        pulseview
        gtkwave
      ];

      programs.fish = {
        interactiveShellInit = ''
          set -gx COLORTERM truecolor
          alias surfer $HOME/g/surfer/target/release/surfer
        '';
      };
    };

    services.comenzar.enable = true;

    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
      taps = [
        "homebrew/cask-fonts"
        "homebrew/services"
      ];
      brews = [
        "libftdi"
        "llvm@18" # zig 0.13
        "pkg-config"
        "zstd" # zig
      ];
      casks =
        [
          # Essentials/miscellaeny.
          "1password"
          "balenaetcher"
          "canon-eos-utility"
          "dosbox-x"
          "daisydisk"
          "eloston-chromium"
          "firefox"
          "keybase"
          "kindle"
          "obsidian"
          "rectangle"
          "syncthing"
          "transmission"
          "transmission-remote-gui"
          "vlc"
          "yubico-authenticator"
        ]
        ++ [
          # Dev tools.
          "kicad"
          "utm"
        ]
        ++ [
          # Communications.
          "element"
          "signal"
        ]
        ++ [
          # Darknet/cryptocurrency.
          "tor-browser"
          "bitcoin-core"
          "ledger-live"
          "monero-wallet"
        ]
        ++ [
          # Fonts.
          "font-atkinson-hyperlegible"
          "font-bangers"
          "font-comic-mono"
          "font-go"
          "font-iosevka"
          "font-iosevka-slab"
          "font-lato"
          "font-open-sans"
          "sf-symbols"
        ]
        ++ [
          # Don't need now but do need sometimes:
          # "ableton-live-lite"
          # "anki"
          # "audacity" -- add "ffmpeg" brew too.
          # "multipass"
          # "musescore"
          # "scrivener"
          # "wireshark"
          # "xld"
          # "yubico-yubikey-manager"
        ];
    };
  };
}
