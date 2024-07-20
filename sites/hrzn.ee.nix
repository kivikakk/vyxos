{...}: {
  config.vyxos.nginx.vhosts = {
    "hrzn.ee" = {
      locations."/".root = ./hrzn.ee;
    };
  };
}
