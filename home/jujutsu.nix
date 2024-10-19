{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        default-command = ["status" "--no-pager"];
      };
    };
  };
}
