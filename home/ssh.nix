{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks = rec {
      seraphim.user = "kivikakk";
      orav.user = "kivikakk";
    };
  };
}
