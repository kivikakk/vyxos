{
  system,
  nixpkgs,
}: let
  pkgs = import nixpkgs {inherit system;};
in
  pkgs.stdenv.mkDerivation {
    name = "vyxnix-check";
    src = ./.;
    doCheck = true;
    dontBuild = true;

    # Note we don't actually use _our_ fish here. TODO.
    nativeBuildInputs = with pkgs; [fish];

    checkPhase = ''
      fish -c '
        source ${../modules/fish/vyxnix.fish}
        source ${../modules/fish/vyxnix-check.fish}
      '
    '';

    installPhase = ''
      mkdir $out
    '';
  }
