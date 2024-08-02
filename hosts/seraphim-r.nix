{
  config,
  pkgs,
  lib,
  vyxUser,
  hostName,
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
      home.packages = [pkgs.fzf];
      # XXX: Hecc this
      home.file.".ssh/radiopaedia.pem".source = config.lib.file.mkOutOfStoreSymlink "/Users/kivikakk/.ssh/id_ed25519";
      # XXX: This may or may not correctly instantiate correctly without first
      # building with just the secret above. If so -- sorry!
      home.file.".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink vyxos.secrets.decrypted."aws-credentials".path;
    };
}
