{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Asherah Connor";
        email = "ashe@kivikakk.ee";
      };
      ui = {
        default-command = ["status"];
        paginate = "never";
      };
    };
  };
}
