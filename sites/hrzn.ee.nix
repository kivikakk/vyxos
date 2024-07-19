{...}: {
  config.vyxos.nginx.vhosts = {
    "hrzn.ee" = {
      publicLinks."hrzn.ee" = ./hrzn.ee;
      locations."/".root = "/home/www/public/hrzn.ee";
    };
  };
}
