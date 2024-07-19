{...}: {
  config.vyxos.nginx.vhosts = {
    "eka.kivikakk.ee" = {
      publicLinks."eka.kivikakk.ee" = ./eka.kivikakk.ee;
      locations."/".root = "/home/www/public/eka.kivikakk.ee";
    };
  };
}
