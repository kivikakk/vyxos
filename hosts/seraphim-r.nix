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
}
