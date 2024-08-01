{
  config,
  pkgs,
  lib,
  ...
}: {
  homebrew = {
    brews = ["awscli"];
    casks = ["mattermost"];
  };

  vyxos.secrets.encrypted = {
    "aws-credentials" = {};
  };

  home-manager.users.${config.vyxos.vyxUser} = let
    inherit (config) vyxos;
  in
    {config, ...}: {
      # XXX: This may or may not correctly instantiate correctly without first
      # building with just the secret above. If so -- sorry!
      home.file.".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink vyxos.secrets.decrypted."aws-credentials".path;
    };
}
