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
      // builtins.mapAttrs (name: _v: "git ${name}") config.programs.git.aliases
      // builtins.mapAttrs (name: _v: "ssh ${name}") config.programs.ssh.matchBlocks;
    functions = let
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
        "qi" = "squash -i";
        "p" = "split";
        "r" = "rebase";
        "b" = "bookmark set";
        "gp" = "git push";
        "gf" = "git fetch";
        "v" = "resolve";
        "" = "";
      };
    in
      lib.concatMapAttrs (lhs: rhs: {
        "A${lhs}" = {
          body = "JJ_USER='Asherah Connor' JJ_EMAIL='ashe@kivikakk.ee' J ${rhs} $argv";
          description = "jj ${rhs}";
          wraps = "J ${rhs}";
        };
        "C${lhs}" = {
          body = "JJ_USER='Charlotte' JJ_EMAIL='charlotte@lottia.net' J ${rhs} $argv";
          description = "jj ${rhs}";
          wraps = "J ${rhs}";
        };
      })
      jjAliases;
  };
  home.file = {
    ".config/fish/functions/blognew.fish".source = ./blognew.fish;
    ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
    ".config/fish/functions/J.fish".source = ./J.fish;
  };
}
