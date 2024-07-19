{
  pkgs,
  isServer,
  ...
}: {
  programs.tmux = {
    enable = true;

    shell = "${pkgs.fish}/bin/fish";
    prefix =
      if isServer
      then "C-r"
      else "C-t";
    keyMode = "vi";

    mouse = true;
    escapeTime = 0;
    historyLimit = 100000;

    terminal = "xterm-256color";
    clock24 = true;

    extraConfig = ''
      ${
        if isServer
        then ""
        else "setw -g monitor-activity on"
      }

      bind c new-window -c "#{pane_current_path}"
      bind m set monitor-activity
      bind S setw synchronize-panes

      bind -n S-Left select-pane -L
      bind -n S-Right select-pane -R
      bind -n S-Up select-pane -U
      bind -n S-Down select-pane -D

      bind -n M-S-Left previous-window
      bind -n M-S-Right next-window

      set -g status-left ' #[fg=white,bold]#h #S#[default] '
      set -g status-left-length 20
      set -g status-bg ${
        if isServer
        then "red"
        else "blue"
      }
      set -g status-right ' #[fg=cyan,bold]%Y-%m-%d %H:%M:%S#[default] '

      # pane border
      set-option -g pane-border-style fg=colour235 #base02
      set-option -g pane-active-border-style fg=colour240 #base01

      # pane number display
      set-option -g display-panes-active-colour colour33 #blue
      set-option -g display-panes-colour colour166 #orange

      # clock
      set-window-option -g clock-mode-colour colour64 #green

      # default statusbar colors
      set-option -g status-style fg=white,bg=default,default

      # default window title colors
      set-window-option -g window-status-style fg=white,bg=default

      # active window title colors
      set-window-option -g window-status-current-style fg=white,bg=default,bright

      # command/message line colors
      set-option -g message-style fg=white,bg=black,bright

      set -g status-left-length 32
      set -g status-right-length 150

    '';
  };
}
