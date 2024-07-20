{...}: {
  config.vyxos.nginx.vhosts = {
    "kivikakk.ee" = {
      locations."/" = {
        root = ./kivikakk.ee;
        tryFiles = "$uri $uri/index.html /archive$uri =404";
        extraConfig = ''
          expires 6h;
          add_header Cache-Control "public, no-transform";
        '';
      };
      locations."/notes".return = "301 https://lottia.net$request_uri";

      locations."/2013/05/10/snapchat.html".return = "301 https://$host/2013/05/10/snapchat/";
      locations."/2012/04/18/escapology.html".return = "301 https://$host/2012/04/18/escapology/";
      locations."/cryptography/2016/02/20/breaking-homegrown-crypto.html".return = "301 https://$host/cryptography/2016/02/20/breaking-homegrown-crypto/";

      # Not running Mastodon/Akkoma anymore.
      locations."/notice/".return = "410";
      locations."/main/ostatus".return = "410";
      locations."/api/".return = "410";
      locations."/media/".return = "410";
      locations."/users/".return = "410";
    };

    "www.kivikakk.ee".locations."/".return = "301 https://kivikakk.ee$request_uri";
  };
}
