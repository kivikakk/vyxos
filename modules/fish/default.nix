{
  config,
  lib,
  isDarwin,
  pkgs,
  ...
}: let
  inherit (config.vyxos) vyxUser;
in {
  config = {
    nixpkgs.config.packageOverrides = oldPkgs: {
      fish = oldPkgs.fish.overrideAttrs {
        patches = [
          ./alias.fish.patch
        ];
        CI = "1"; # XXX: A race test failed when building on sylph.
      };
    };

    environment.shells = [pkgs.fish];
    programs.fish.enable = true;
    users.users.${vyxUser}.shell = pkgs.fish;

    home-manager.users.${vyxUser} = {
      home.file = {
        ".config/fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
        ".config/fish/functions/ZZZ.fish".source = ./ZZZ.fish;
        ".config/fish/functions/blognew.fish".source = ./blognew.fish;
        ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
      };
      programs.fish =
        {
          enable = true;
          shellInit = ''
            set VYXOS $HOME/g/vyxos
          '';
          shellAliases = {
            ZZ = "$VYXOS/rebuild switch";
          };
        }
        // lib.optionalAttrs isDarwin {
          loginShellInit = ''
            for p in (string split " " $NIX_PROFILES)
              fish_add_path -p -m $p/bin
            end
          '';
        };
    };
  };
}
