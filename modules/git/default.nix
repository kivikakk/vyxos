{vyxos-git-base, ...}: {
  config = {
    nixpkgs.config.packageOverrides = oldPkgs: {
      vyxos-git = vyxos-git-base.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        patches = [
          ./pretty.c.patch
        ];
      };
    };
  };
}
