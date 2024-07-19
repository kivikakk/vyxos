{...}: {
  programs.ssh = {
    enable = true;
    # TODO: generate from hosts.toml. Why not?
    matchBlocks = rec {
      seraphim.user = "kivikakk";
      orav.user = "kivikakk";
    };
  };
}
