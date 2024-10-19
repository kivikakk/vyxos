{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        default-command = ["status"];
        paginate = "never";
      };
    };
  };
}
