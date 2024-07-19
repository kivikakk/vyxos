{
  lib,
  hostName,
  ...
}: let
  allHostData = lib.importTOML ../hosts.toml;
in {
  programs.ssh = {
    enable = true;
    matchBlocks = let
      f = acc: host: hostConf:
        acc // {${host} = {user = hostConf.user;};};
    in
      lib.foldlAttrs f {} allHostData;
  };
}
