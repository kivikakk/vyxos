{
  nixpkgs,
  system,
  hostName,
}: {
  root = {
    imports = [
      "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    ];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/9ca66df7-2812-470b-9ac7-69594af39e38";
        fsType = "btrfs";
        options = ["subvol=@"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/12CE-A600";
        fsType = "vfat";
        options = ["fmask=0022" "dmask=0022"];
      };
    };

    boot.initrd.luks.devices = {
      "luks-9199b301-3f97-4c18-8149-9ff01094c792".device = "/dev/disk/by-uuid/9199b301-3f97-4c18-8149-9ff01094c792";
      "luks-e7d3a4b7-7ac7-466e-b402-dbe5b34a616c".device = "/dev/disk/by-uuid/e7d3a4b7-7ac7-466e-b402-dbe5b34a616c";
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/0463f7f5-d50b-4a87-afc0-9c0b737e801d";}
    ];
  };

  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    system.stateVersion = "24.05";
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    networking.useDHCP = lib.mkDefault true;
    networking.networkmanager.enable = true;

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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

    users.users.kivikakk.extraGroups = ["networkmanager"];

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
        polkitPolicyOwners = ["kivikakk"];
      };
    };

    environment.systemPackages = with pkgs; [
      iosevka
    ];

    vyxos = {
      desktop.enable = true;
      secrets = {
        additionalAuthorizedKeys = [
          "kivikakk-celica"
          "kivikakk-estrellita"
        ];
        encrypted = {
          "aerc-password" = {};
        };
      };
    };

    home-manager.users.${config.vyxos.vyxUser} = {
      accounts.email.accounts.asherah.passwordCommand = "cat ${config.vyxos.secrets.decrypted."aerc-password".path}";
    };

    services.tailscale.enable = true;
  };
}
