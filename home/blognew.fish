function blognew
  set prefix (date +%Y-%m-%d-)

  if test (count $argv) -ne 1
    echo "usage: blognew ID"
    echo "will create a post like "$prefix"ID.md"
    return 1
  end

  cd ~/g/kivikakk.ee/jekyll/

  set fn _posts/"$prefix""$argv[1]".md
  echo >$fn '---
layout:      post
title:       "Henlo"
---

Hi.'
  echo $fn created.
  hx $fn
end
