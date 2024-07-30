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
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    vyxos.secrets = {
      additionalAuthorizedKeys = [
        "kivikakk-celica"
        "kivikakk-estrellita"
      ];
      encrypted = {
        "aerc-password" = {};
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

      home.packages = [
        pkgs.pulseview
        pkgs.gtkwave
        pkgs.rustup
        pkgs.entr
      ];

      programs.fish = {
        shellAliases = {
          aerc = "XDG_CONFIG_HOME=$HOME/.config command aerc";
        };

        interactiveShellInit = ''
          set -gx COLORTERM truecolor
          source $HOME/.asdf/asdf.fish
          fish_add_path /opt/homebrew/opt/postgresql@13/bin
          fish_add_path /opt/homebrew/bin
          fish_add_path $HOME/.cargo/bin
          fish_add_path $HOME/g/zig/build/stage3/bin
          fish_add_path $HOME/.local/bin
          fish_add_path $HOME/.ghcup/bin
          fish_add_path $HOME/.cabal/bin
          fish_add_path $HOME/g/zls/zig-out/bin
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
        "libyaml" # our asdf ruby build needs this
        "llvm@17" # zig 0.12
        "llvm@18" # zig 0.13
        "pkg-config"
        "postgresql@13"
        "verilator" # can't install via nixpkgs, broken systemc dep
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
          "iterm2"
          "kicad"
          "utm"
          "visual-studio-code"
        ]
        ++ [
          # Communications.
          "element"
          "jitsi-meet"
          "signal"
          "telegram"
          "messenger"
        ]
        ++ [
          # Darknet/cryptocurrency.
          "tor-browser"
          "bitcoin-core"
          "ledger-live"
          "monero-wallet"
          "onekey"
        ]
        ++ [
          # Fonts.
          "font-atkinson-hyperlegible"
          "font-bangers"
          "font-comic-mono"
          "font-go"
          "font-iosevka"
          "font-iosevka-slab"
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
