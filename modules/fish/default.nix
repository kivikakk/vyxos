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
        ".config/fish/functions/vyxnix.fish".source = ./vyxnix.fish;
        ".config/fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
        ".config/fish/functions/fish_jj_prompt.fish".source = ./fish_jj_prompt.fish;
        ".config/fish/functions/fish_vcs_prompt.fish".source = ./fish_vcs_prompt.fish;
        ".config/fish/functions/nix_shell_info.fish".source = ./nix_shell_info.fish;
        ".config/fish/functions/ZZZ.fish".source = ./ZZZ.fish;
      };
      programs.fish =
        {
          enable = true;
          shellInit = ''
            set VYXOS $HOME/g/vyxos
            # Don't allow state to accumulate.
            rm -f $HOME/.config/fish/fish_variables &>/dev/null
          '';
          shellAliases = {
            ZZ = "$VYXOS/rebuild switch";
            VZ = "cd $VYXOS";
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
