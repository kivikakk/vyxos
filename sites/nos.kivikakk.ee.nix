{config, ...}: {
  vyxos = {
    nginx.vhosts."nos.kivikakk.ee" = {
      locations."/" = {
        # XXX: needs to keep up-to-date with the nos version number?
        # Find the better way of doing this.
        root = "${config.services.nos.package}/lib/nos-0.1.0/priv/static";
        tryFiles = "$uri @backend";
      };
      locations."@backend" = {
        proxyPass = "http://localhost:6500";
        recommendedProxySettings = true;
      };
    };
    secrets.encrypted."nos-secret-key" = {
      owner = config.services.nos.user;
    };
  };

  services.nos = {
    enable = true;
    port = 6500;
    host = "nos.kivikakk.ee";
    secretKeyBaseFile = config.vyxos.secrets.decrypted."nos-secret-key".path;
  };
}
