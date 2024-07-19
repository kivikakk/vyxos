{
  nixpkgs,
  system,
  hostName,
}: {
  root = {
    imports = [
      # Without this we don't find /dev/sda1 on boot :)
      "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    ];

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;
    services.udev.extraRules = ''
      ATTR{address}=="96:00:03:85:50:66", NAME="eth0"
    '';
    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
    boot.initrd.kernelModules = ["nvme"];
    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };

  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [
      ../sites
    ];

    nixpkgs = {
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "outline"
          ];
      };
    };

    vyxos = {
      secrets = {
        additionalAuthorizedKeys = [
          "kivikakk-celica"
          "kivikakk-estrellita"
        ];
        encrypted = {
          "furpoll-cookie" = {};
          "smtpd-auth-table" = {};
        };
      };
      nginx = {
        enable = true;
        vhosts = {
          "orav.hrzn.ee" = {
            locations."/".return = "502";
          };
        };
      };
    };

    users.users = {
      kinu = {
        isNormalUser = true;
        home = "/home/kinu";
        description = "Kinu";
        group = "nginx";
        createHome = true;
        homeMode = "710";
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../sources/kinu-orav-id_ed25519.pub)
        ];
        extraGroups = ["users"];
      };
    };

    environment.systemPackages = [
      # For sendmail or something?
      config.services.opensmtpd.package
    ];

    services = {
      tailscale.enable = true;
      postgresql.package = pkgs.postgresql_14;

      furpoll = {
        enable = true;
        calendar = "*-*-* 7,10,13,18,21,23:07:00";
        from = "furpoll <furpoll@kivikakk.ee>";
        to = "Ashe <ashe@kivikakk.ee>";

        cookieFile = config.vyxos.secrets.decrypted."furpoll-cookie".path;
      };

      opensmtpd = {
        enable = true;
        serverConfiguration = ''
          queue compression

          table fastmail file:${config.vyxos.secrets.decrypted."smtpd-auth-table".path}

          listen on lo

          action "fastmail" relay host "smtps://orav@smtp.fastmail.com:565" auth <fastmail>

          match for any from local action "fastmail"
        '';
      };
    };
  };
}
