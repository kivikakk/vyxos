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
        jj = "echo use aj/cj";
      }
      // (let
        jjAliases = {
          "d" = "diff";
          "h" = "show";
          "l" = "log";
          "m" = "describe -m";
          "n" = "new";
          "a" = "abandon";
          "q" = "squash";
          "p" = "split";
          "r" = "rebase";
          "b" = "bookmark set";
          "gp" = "git push";
          "gf" = "git fetch";
        };
      in
        lib.concatMapAttrs (lhs: rhs: {
          "aj${lhs}" = "aj ${rhs}";
          "cj${lhs}" = "cj ${rhs}";
        })
        jjAliases)
      // builtins.mapAttrs (name: _v: "git ${name}") config.programs.git.aliases
      // builtins.mapAttrs (name: _v: "ssh ${name}") config.programs.ssh.matchBlocks;
  };
  home.file = {
    ".config/fish/functions/blognew.fish".source = ./blognew.fish;
    ".config/fish/functions/blogserve.fish".source = ./blogserve.fish;
    ".config/fish/functions/aj.fish".source = ./aj.fish;
    ".config/fish/functions/cj.fish".source = ./cj.fish;
  };
}
