# This is very important.
{...}: {
  config.nixpkgs.config.packageOverrides = oldPkgs: {
    cowsay = oldPkgs.cowsay.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [./bovine.patch];
    });
  };
}
