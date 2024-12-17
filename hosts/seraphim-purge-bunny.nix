{
  config,
  pkgs,
  ...
}: let
  purge-bunny = pkgs.writeScriptBin "purge-bunny" ''
    #!${pkgs.fish}/bin/fish
    set access_key (cat ${config.vyxos.secrets.decrypted."bunny-api".path})
    set zone_ids (cat ${config.vyxos.secrets.decrypted."bunny-zone-ids".path})

    for zone_id in $zone_ids
        curl --request POST \
            --url https://api.bunny.net/pullzone/$zone_id/purgeCache \
            --header 'AccessKey: '$access_key \
            --header 'content-type: application/json'
    end
  '';
in {
  vyxos.secrets.encrypted = {
    "bunny-api" = {};
    "bunny-zone-ids" = {};
  };

  home-manager.users.${config.vyxos.vyxUser} = {
    home.packages = [
      purge-bunny
    ];
  };
}
