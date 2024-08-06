{...}: {
  home.sessionVariables.EDITOR = "hx";

  programs.helix = {
    enable = true;
    settings = {
      theme = "horizon-dark";
      keys = {
        normal.Z.Z = ":write-quit";
        normal.C-q = ":reflow";
        normal.D = "kill_to_line_end";
        normal.ret = "move_line_down";
        normal.S-tab = "jump_backward";
      };
      editor = {
        true-color = true;
        auto-pairs = false;
        cursorline = true;
        rulers = [100];
        bufferline = "multiple";
        statusline = {
          left = ["mode" "spinner" "file-name" "file-modification-indicator" "spacer" "version-control"];
        };
        file-picker = {
          hidden = false;
        };
        whitespace = {
          render = {
            space = "none";
            newline = "none";
            tab = "all";
            nbsp = "all";
          };
        };
      };
    };
    languages = {
      language = [
        {
          name = "typescript";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
        {
          name = "tsx";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];
    };
  };
}
