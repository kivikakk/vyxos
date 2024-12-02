{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Asherah Connor";
    userEmail = "ashe@kivikakk.ee";
    extraConfig = {
      github.token = builtins.readFile ../private/secrets/github-token;
      init.defaultBranch = "main";
      merge.conflictStyle = "zdiff3";
      push.default = "upstream";
      pull.rebase = true;
      advice.detachedHead = false;
    };
    ignores = [
      ".*.sw*"
      ".DS_Store"
    ];
    aliases = import ./git-aliases.nix;
  };
}
