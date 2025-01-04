{
  description = "seraphim, piret + kala";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;

    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    fish-beta-nixpkgs.url = github:NixOS/nixpkgs/fish;
    ghostty-nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    nix-darwin = {
      url = github:LnL7/nix-darwin/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager/release-24.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    furpoll = {
      url = git+https://github.com/kivikakk/furpoll;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixos-hardware.url = github:NixOS/nixos-hardware;

    comenzar = {
      url = git+https://github.com/kivikakk/comenzar;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    plasma-manager = {
      url = github:nix-community/plasma-manager;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    jj = {
      url = github:charlottia/jj/ssh-openssh;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    lanzaboote = {
      url = github:nix-community/lanzaboote/v0.4.1;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "jj/rust-overlay";
    };
  };

  outputs = inputs @ {
    self,
    flake-utils,
    nixpkgs,
    fish-beta-nixpkgs,
    ghostty-nixpkgs,
    nix-darwin,
    home-manager,
    sops-nix,
    furpoll,
    nixos-hardware,
    comenzar,
    plasma-manager,
    jj,
    lanzaboote,
  }: let
    mkHost = hostName: system: specifiedModules: let
      isDarwin = builtins.elem system nixpkgs.lib.platforms.darwin;
      specifics =
        {
          nixos = {
            nixpkgs = nixpkgs;
            nixSystem = nixpkgs.lib.nixosSystem;
            modules = [
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              furpoll.nixosModules.${system}.default
              comenzar.nixosModules.${system}.default
              {
                nixpkgs.overlays = [
                  (final: prev: {
                    ghostty = (import ghostty-nixpkgs {inherit system;}).ghostty;
                  })
                ];
              }
            ];
            hm-modules = [
              sops-nix.homeManagerModules.sops
              plasma-manager.homeManagerModules.plasma-manager
            ];
          };
          darwin = {
            nixpkgs = nixpkgs;
            nixSystem = nix-darwin.lib.darwinSystem;
            modules = [
              home-manager.darwinModules.home-manager
              comenzar.darwinModules.${system}.default
            ];
            hm-modules = [
              sops-nix.homeManagerModules.sops
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
    in
      specifics.nixSystem {
        inherit system;
        specialArgs = {
          inherit (specifics) nixpkgs;
          inherit isDarwin hostName lib;
        };

        modules =
          [
            ./common.nix
            freezeRegistry
            ./modules
          ]
          ++ specifics.modules
          ++ [
            {
              nixpkgs.overlays = [
                (final: prev: {
                  fish = (import fish-beta-nixpkgs {inherit system;}).fish;
                })
              ];
            }
          ]
          ++ [
            hostRootModule
            hostConfig.module
          ]
          ++ homeManagerModules
          ++ specifiedModules;
      };
  in
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
      checks.vyxnix = import ./tests/vyxnix.nix {inherit system nixpkgs;};
    })
    // {
      nixosConfigurations = {
        kala = mkHost "kala" "x86_64-linux" [];
        piret = mkHost "piret" "x86_64-linux" [
          nixos-hardware.nixosModules.framework-16-7040-amd
          lanzaboote.nixosModules.lanzaboote
          {nixpkgs.overlays = [jj.overlays.default];}
        ];
      };
      darwinConfigurations = {
        seraphim = mkHost "seraphim" "aarch64-darwin" [
          {nixpkgs.overlays = [jj.overlays.default];}
        ];
      };
    };
}
