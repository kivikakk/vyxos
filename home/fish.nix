{
  config,
  lib,
  ...
}: {
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
        nr = "vyxnix run";
        ns = "vyxnix shell";
        jj = "echo use A/C";
      }
      // (let
        jjAliases = {
          "d" = "diff";
          "h" = "show";
          "l" = "log";
          "ln" = "log --no-pager";
          "m" = "describe -m";
          "mm" = "describe";
          "n" = "new";
          "e" = "edit";
          "a" = "abandon";
          "z" = "restore";
          "q" = "squash";
          "p" = "split";
          "r" = "rebase";
          "b" = "bookmark set";
          "gp" = "git push";
          "gf" = "git fetch";
          "v" = "resolve";
        };
      in
        lib.concatMapAttrs (lhs: rhs: {
          "A${lhs}" = "A ${rhs}";
          "C${lhs}" = "C ${rhs}";
        })
        jjAliases)
      // builtins.mapAttrs (name: _v: "git ${name}") config.programs.git.aliases
      // builtins.mapAttrs (name: _v: "ssh ${name}") config.programs.ssh.matchBlocks;
  };
  home.file = {
    ".config/fish/functions/blognew.fish".source = ./blognew.fish;
    ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
    ".config/fish/functions/A.fish".source = ./A.fish;
    ".config/fish/functions/C.fish".source = ./C.fish;
  };
}
