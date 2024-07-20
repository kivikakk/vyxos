{...}: {
  config.vyxos.nginx.vhosts = {
    "lottia.net" = {
      locations."/".return = "301 https://lottia.net/notes/";
      locations."/notes" = {
        root = ./lottia.net;
        extraConfig = ''
          expires 6h;
          add_header Cache-Control "public, no-transform";
        '';
      };

      # Not running Mastodon/Akkoma anymore.
      locations."/notice/".return = "410";
      locations."/main/ostatus".return = "410";
      locations."/api/".return = "410";
      locations."/media/".return = "410";
      locations."/users/".return = "410";
    };
  };
}
