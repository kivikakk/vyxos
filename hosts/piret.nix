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

    vyxos = {
      desktop.enable = true;
      secrets = {
        additionalAuthorizedKeys = [
          "kivikakk-celica"
          "kivikakk-estrellita"
        ];
        encrypted = {
          "aerc-password" = {
            owner = config.vyxos.vyxUser;
            group = config.users.users.${config.vyxos.vyxUser}.group;
          };
        };
      };
    };

    home-manager.users.${config.vyxos.vyxUser} = {
      accounts.email.accounts.asherah.passwordCommand = "cat ${config.vyxos.secrets.decrypted."aerc-password".path}";
    };

    services.tailscale.enable = true;
    services.comenzar.enable = true;
  };
}
