{...}: {
  config.vyxos.nginx.vhosts = {
    "lottia.net" = {
      publicLinks."notes" = ./notes;
      locations."/".return = "301 https://lottia.net/notes/";
      locations."/notes".root = "/home/www/public";

      # Not running Mastodon/Akkoma anymore.
      locations."/notice/".return = "410";
      locations."/main/ostatus".return = "410";
      locations."/api/".return = "410";
      locations."/media/".return = "410";
      locations."/users/".return = "410";
    };
  };
}
