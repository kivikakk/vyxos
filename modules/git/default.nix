{
  config,
  lib,
  ...
}: {
  config = {
    nixpkgs.config.packageOverrides = oldPkgs: {
      vyxos-git = oldPkgs.git;
      # TODO: reintroduce. This doesn't apply on the git in nixos-unstable.
      # XXX: for now I'm leaving the "% cm" in the git log alias to remind me to fix this.
      # vyxos-git = oldPkgs.git.overrideAttrs {
      #   doCheck = false;
      #   patches = [
      #     ./pretty.c.patch
      #   ];
      # };
    };
  };
}
