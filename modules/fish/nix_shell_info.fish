function nix_shell_info
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
end
