{...}: {
  config.vyxos.nginx.vhosts = {
    "eka.kivikakk.ee" = {
      locations."/".root = ./eka.kivikakk.ee;
    };
  };
}
