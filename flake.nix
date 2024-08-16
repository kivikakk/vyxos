{
  description = "seraphim + orav";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;

    unstable-nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    unstable-home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "unstable-nixpkgs";
    };
    unstable-sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "unstable-nixpkgs";
    };
    unstable-furpoll = {
      url = git+https://github.com/kivikakk/furpoll;
      inputs.nixpkgs.follows = "unstable-nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    unstable-nixos-hardware.url = github:NixOS/nixos-hardware;
    unstable-comenzar = {
      url = git+https://github.com/kivikakk/comenzar;
      inputs.nixpkgs.follows = "unstable-nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    unstable-plasma-manager = {
      url = github:nix-community/plasma-manager;
      inputs.nixpkgs.follows = "unstable-nixpkgs";
      inputs.home-manager.follows = "unstable-home-manager";
    };

    darwin-nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-24.05-darwin;
    darwin-nix-darwin = {
      url = github:LnL7/nix-darwin/master;
      inputs.nixpkgs.follows = "darwin-nixpkgs";
    };
    darwin-home-manager = {
      url = github:nix-community/home-manager/release-24.05;
      inputs.nixpkgs.follows = "darwin-nixpkgs";
    };
    darwin-sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "darwin-nixpkgs";
    };
    darwin-comenzar = {
      url = git+https://github.com/kivikakk/comenzar;
      inputs.nixpkgs.follows = "darwin-nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    self,
    flake-utils,
    unstable-nixpkgs,
    unstable-home-manager,
    unstable-sops-nix,
    unstable-furpoll,
    unstable-nixos-hardware,
    unstable-comenzar,
    unstable-plasma-manager,
    darwin-nixpkgs,
    darwin-nix-darwin,
    darwin-home-manager,
    darwin-sops-nix,
    darwin-comenzar,
  }: let
    mkHost = hostName: system: specifiedModules: let
      isDarwin = builtins.elem system unstable-nixpkgs.lib.platforms.darwin;
      specifics =
        {
          nixos = {
            nixpkgs = unstable-nixpkgs;
            nixSystem = unstable-nixpkgs.lib.nixosSystem;
            modules = [
              unstable-home-manager.nixosModules.home-manager
              unstable-sops-nix.nixosModules.sops
              unstable-furpoll.nixosModules.${system}.default
              unstable-comenzar.nixosModules.${system}.default
            ];
            hm-modules = [
              unstable-sops-nix.homeManagerModules.sops
              unstable-plasma-manager.homeManagerModules.plasma-manager
            ];
          };
          darwin = {
            nixpkgs = darwin-nixpkgs;
            nixSystem = darwin-nix-darwin.lib.darwinSystem;
            modules = [
              darwin-home-manager.darwinModules.home-manager
              darwin-comenzar.darwinModules.${system}.default
            ];
            hm-modules = [
              darwin-sops-nix.homeManagerModules.sops
            ];
          };
        }
        .${
          if isDarwin
          then "darwin"
          else "nixos"
        };
    in let
      hostConfig = import ./hosts/${hostName}.nix {
        inherit (specifics) nixpkgs;
        inherit system hostName;
      };
      lib = specifics.nixpkgs.lib.extend (final: prev: {
        # …
      });
      freezeRegistry = {
        nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
      };
      hostRootModule =
        {
          system.configurationRevision =
            if (self ? rev)
            then self.rev
            else throw "refuse to build: git tree is dirty";
        }
        // hostConfig.root;
      homeManagerModules = [
        ({config, ...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${config.vyxos.vyxUser} = import ./home.nix;
            sharedModules = specifics.hm-modules;
            extraSpecialArgs = {
              inherit isDarwin;
              inherit (config.vyxos) isServer;
            };
          };
        })
      ];
      vyxos-git-base = unstable-nixpkgs.legacyPackages.${system}.git;
    in
      specifics.nixSystem {
        inherit system;
        specialArgs = {
          inherit (specifics) nixpkgs;
          inherit isDarwin hostName lib vyxos-git-base;
        };

        modules =
          [
            ./common.nix
            freezeRegistry
            ./modules
          ]
          ++ specifics.modules
          ++ [
            hostRootModule
            hostConfig.module
          ]
          ++ homeManagerModules
          ++ specifiedModules;
      };
  in
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = unstable-nixpkgs.legacyPackages.${system}.alejandra;
      checks.vyxnix = import ./tests/vyxnix.nix {inherit system unstable-nixpkgs;};
    })
    // {
      nixosConfigurations = {
        orav = mkHost "orav" "x86_64-linux" [];
        piret = mkHost "piret" "x86_64-linux" [
          unstable-nixos-hardware.nixosModules.framework-16-7040-amd
        ];
      };
      darwinConfigurations = {
        seraphim = mkHost "seraphim" "aarch64-darwin" [];
      };
    };
}
