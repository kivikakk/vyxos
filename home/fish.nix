{config, ...}: {
  programs.fish = {
    interactiveShellInit = ''
      set __fish_git_prompt_show_informative_status 1
      set __fish_git_prompt_showcolorhints 1
      set __fish_git_prompt_showdirtystate 1
      set __fish_git_prompt_showstashstate 1
      set __fish_git_prompt_showuntrackedfiles 1
    '';
    shellAliases =
      {
        "." = "ls";
        py = "python";
        nb = "vyxnix build";
        nd = "vyxnix develop";
        nl = "vyxnix log";
        nf = "vyxnix fmt";
        nfc = "vyxnix flake check";
        nfu = "vyxnix flake update";
        nflui = "vyxnix flake lock --update-input";
        nr = "vyxnix run";
      }
      // builtins.mapAttrs (name: _v: "git ${name}") config.programs.git.aliases
      // builtins.mapAttrs (name: _v: "ssh ${name}") config.programs.ssh.matchBlocks;
    functions = {
      nix_shell_info = ''
        if test -n "$name" -a "$name" != "shell"
          echo -n " <"
          set_color blue
          echo -n "$name"
          set_color normal
          echo -n ">"
        else if test -n "$IN_NIX_SHELL"
          echo -n " <"
          set_color magenta
          echo -n "ns"
          set_color normal
          echo -n ">"
        end
      '';
    };
  };
  home.file = {
    ".config/fish/functions/blognew.fish".source = ./blognew.fish;
    ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
  };
}
