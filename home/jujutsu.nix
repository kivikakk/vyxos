{config, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        default-command = ["status" "--no-pager"];
        diff-editor = ":builtin";
        merge-editor = ":builtin";
      };
      git.private-commits = "description(glob:'!!*')";
    };
  };
}
