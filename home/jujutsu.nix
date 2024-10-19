{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "ashe@kivikakk.ee";
        name = "Asherah Connor";
      };
      ui = {
        default-command = ["status" "--no-pager"];
      };
    };
  };
}
