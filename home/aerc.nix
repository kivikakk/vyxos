{config, ...}: {
  accounts.email.accounts = {
    asherah = {
      primary = true;
      address = "ashe@kivikakk.ee";
      realName = "Asherah Connor";

      userName = "ashe@kivikakk.ee";
      imap.host = "imap.fastmail.com";
      smtp.host = "smtp.fastmail.com";

      folders.inbox = "INBOX";

      aerc = {
        enable = true;
        extraAccounts = {
          folders-sort = "INBOX";
          folders-exclude = "~^Archive,Notes";
        };
      };
    };
  };

  programs.aerc = {
    enable = true;
    # Starting with the default binds, since home-manager 23.05's aerc module
    # improperly always creates binds.conf, even if nothing is configured,
    # thus unsetting all binds.
    extraBinds = builtins.readFile ./aerc-binds.conf;

    extraConfig = {
      # https://github.com/nix-community/home-manager/blob/0f4e5b4999fd6a42ece5da8a3a2439a50e48e486/modules/programs/aerc.nix#L167-L177
      general.unsafe-accounts-conf = true;

      filters = {
        "text/plain" = "colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/html" = "pandoc -f html -t plain | colorize";
      };
    };
  };
}
