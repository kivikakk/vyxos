{config, ...}: {
  programs.fish = {
    interactiveShellInit = ''
      set __fish_git_prompt_show_informative_status 1
      set __fish_git_prompt_showcolorhints 1
      set __fish_git_prompt_showdirtystate 1
      set __fish_git_prompt_showstashstate 1
      set __fish_git_prompt_showuntrackedfiles 1
      set fish_greeting 'Nyonk!'
    '';
    shellAliases =
      {
        "." = "eza --git --git-repos";
        py = "python";
        nb = "vyxnix build";
        nd = "vyxnix develop";
        nl = "vyxnix log";
        nf = "vyxnix fmt";
        nfc = "vyxnix flake check";
        nfu = "vyxnix flake update";
        nflui = "vyxnix flake lock --update-input";
        nr = "vyxnix run";
        ns = "vyxnix shell";
        aj = "jj --config-toml 'user = {\"name\" = \"Asherah Connor\", \"email\" = \"ashe@kivikakk.ee\"}'";
        cj = "jj --config-toml 'user = {\"name\" = \"Charlotte\", \"email\" = \"charlotte@lottia.net\"}'";
      }
      // builtins.mapAttrs (name: _v: "git ${name}") config.programs.git.aliases
      // builtins.mapAttrs (name: _v: "ssh ${name}") config.programs.ssh.matchBlocks;
  };
  home.file = {
    ".config/fish/functions/blognew.fish".source = ./blognew.fish;
    ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
  };
}
