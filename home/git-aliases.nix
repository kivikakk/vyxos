let
  log = "log --show-notes='*' --abbrev-commit --pretty=format:'%Cred%h %Cgreen(%aD)%Creset -%C(bold red)%d%Creset %s %C(bold blue)<%an>% cm%Creset' --graph";
in {
  lc = "!git -c user.name='Lotte' -c user.email='charlotte@lottia.net'";

  cl = "clone";

  co = "checkout";
  cb = "checkout -b";
  pc = "checkout -p";

  s = "status -sb";

  b = "branch";
  ba = "branch -a";
  bd = "branch -d";
  bdd = "branch -D";

  h = "show";
  h1 = "show HEAD^";
  h2 = "show HEAD^^";
  h3 = "show HEAD^^^";
  h4 = "show HEAD^^^^";
  h5 = "show HEAD^^^^^";

  d = "diff";
  dch = "diff --cached";

  l = log;
  lp = "${log} --patch";
  la = "${log} --all";

  a = "add -p";
  ad = "add";

  mrm = "rm";
  mrc = "rm --cached";

  c = "commit";
  cm = "commit -m";
  cx = "commit --amend";
  pcp = "cherry-pick";

  m = "merge";
  mnf = "merge --no-ff";

  r = "reset";
  rh = "reset --hard";

  en = "revert";

  rb = "rebase";
  ri = "rebase -i";
  rbc = "rebase --continue";
  rba = "rebase --abort";

  w = "push";
  wf = "push -f";
  wo = "push origin";
  wu = "push -u";
  v = "pull";
  f = "fetch";
  fa = "fetch --all";

  rv = "remote -v";
  ra = "remote add";
  rp = "remote prune";
  rpo = "remote prune origin";
  rpa = "fetch --all --prune";

  st = "stash";
  sth = "stash show -p";
  stl = "stash list";
  std = "stash drop";
  stp = "stash pop";
  sta = "stash apply";

  sms = "submodule sync --recursive";
  smu = "submodule update --init --recursive";

  bl = "blame";
}
