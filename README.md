# VyxOS

This is a nix-darwin and NixOS configuration in flake format. It's evolved a
**lot** over time, but unfortunately I don't have time to scrub 850 commits for
secrets, so I decided to start history over while funnelling private stuff into
a submodule. The config has contracted enormously in the last few months, so
what's left is what I really [depend upon][cowsay patch]!

[cowsay patch]: modules/cowsay/bovine.patch

A description of the basic layout follows.

* [`flake.nix`](flake.nix) — entrypoint. I use 24.11 on both Darwin and NixOS. Load common config, our modules, host-specific config, Home Manager, and custom jj build.
* [`common.nix`](common.nix) — enables `nix` (or "nix3"), flakes, and flake repl. Ensures `git` is in the system closure, since it's needed for building flakes.
* [`modules`](modules/default.nix) — root of VyxOS modules. Host data is loaded from [`hosts.toml`](hosts.toml), which supplies values used all over.
  * [`modules/secrets`](modules/secrets/default.nix) — secrets management. Provides a simple interface to [sops-nix] and installs SSH public and private keys. Secrets are stored in `private/` and encrypted with sops-nix.
  * [`modules/fish`](modules/fish/default.nix) — Fish custom build and baseline configuration. I adjust [`alias`](modules/fish/alias.fish.patch) to let my git aliases tab-complete. A prompt is installed and some aliases to rebuild VyxOS and [use Nix fluently](#vyxnix). Nix profile paths are added to PATH on Darwin.
  * [`modules/git`](modules/git/default.nix) — custom Git build per [Jambalam - lottia notes][jambalam].
  * [`modules/nix`](modules/nix/default.nix) — configure [extra dependencies] in nix-darwin like we can in NixOS. ([Thanks!][antifuchs])
  * [`modules/cowsay`](modules/cowsay/default.nix) — custom [Cowsay] build. For reasons.
  * [`modules/net`](modules/net/default.nix) — networking configuration for NixOS hosts. This sets the host up based on its `hosts.toml` data.
  * [`modules/nginx`](modules/nginx/default.nix) — a simple interface to configuring vhosts for Nginx, also allowing inclusion of site content as part of the Nix build. Also ensures all vhosts get great 502 behaviour.
  * [`modules/desktop`](modules/desktop/default.nix) — configuration for "desktop" NixOS use.
    * [Iosevka] Term Slab Extended thankyouverymuch.
* [`hosts`](hosts/) — host-specific config.
  * [`hosts/seraphim.nix`](hosts/seraphim.nix) — configures my Macbook (on nix-darwin). Anything macOS-specific goes here.
    * I used to be extremely Serious about not installing anything outside of Nix unless absolutely possible, but I loosened up a lot, so there's also things like sourcing `asdf`, adding `~/.cargo/bin` to PATH and stuff like that.
    * Homebrew is configured declaratively, which is really nice — I'll often `brew install` something manually just to try it out, and let my next rebuild GC it, or add it to the config if I decide to keep it.
    * [Comenzar] is enabled.
  * [`hosts/seraphim-r.nix`](hosts/seraphim-r.nix) — additional configuration for working with a particular client.
  * [`hosts/piret.nix`](hosts/piret.nix) — configures my Framework (on NixOS).
    * Compared to seraphim, devtools here are done entirely within Nix.
    * [Comenzar] is enabled.
  * [`hosts/kala.nix`](hosts/kala.nix) — configures my VPS (on NixOS).
    * Hardware config is stuffed up the top, pulled from a [`nixos-infect`]-generated `hardware-configuration.nix`.
    * Pulls in `sites/`, documented below.
    * [furpoll] is enabled and configured.
    * A baseline vhost for the server's FQDN itself is set which [just returns a 502][502]. (This is important.)
    * Tailscale is enabled.
    * [OpenSMTPD] is configured. It is such a breath of fresh air to configure.
* [`home.nix`](home.nix) — Home Manager config module for the "default" user (i.e. me!). Loads submodules and installs baseline packages.
  * [`home/fish.nix`](home/fish.nix) — sets up Fish for me specifically. Sets prompt git info, adds [`vyxnix`](#vyxnix) aliases, [Git alias passthrough](#git-aliases), [SSH aliases](#ssh-aliases), [jj aliases](#jj), and some I use to write blog posts.
  * [`home/ssh.nix`](home/ssh.nix) — configures SSH. Generates [ssh_config] blocks for each host defined in `hosts.toml`. (These in turn become [shell aliases](#ssh-aliases).)
  * [`home/helix.nix`](home/helix.nix) — sets up [Helix]. (I like typing `ZZ` to save and quit, and why `vgld` when `D` could do? Old habits die hard.)
  * [`home/tmux.nix`](home/tmux.nix) — configures tmux. The prefix is `C-t` on non-servers, and `C-r` on servers, so having a session on your **t**erminal and further sessions on various **r**emotes within that Just Work™. Their statusbars are also coloured differently. (`t` and `r` are also nicely placed on Dvorak.)
  * [`home/git.nix`](home/git.nix) — personal baseline git configuration; pulls in [aliases](#git-aliases).
  * [`home/ripgrep.nix`](home/ripgrep.nix) — minimal rg config (`--hidden` to not exclude "hidden" things by default).
  * [`home/aerc.nix`](home/aerc.nix) — [aerc] (and email account) config.
  * [`home/jujutsu.nix`](home/jujutsu.nix) — jj config.
* [`sites`](sites/default.nix) — web sites, and the services associated with them.
  * [`sites/kivikakk.ee.nix`](sites/kivikakk.ee.nix) — configures [kivikakk.ee]. There's some 301s for old URLs, 410s for when I used to host Fediverse things, and cache headers for my CDN to notice. The actual content is included in [`sites/kivikakk.ee/`](sites/kivikakk.ee/).
  * [`sites/lottia.net.nix`](sites/lottia.net.nix) — configures [lottia.net]. Mostly as above.
  * [`sites/eka.kivikakk.ee.nix`](sites/eka.kivikakk.ee.nix) — configures [eka.kivikakk.ee]. As minimal a definition as it gets.
  * [`sites/hrzn.ee.nix`](sites/hrzn.ee.nix) — configures [hrzn.ee]. As above.
  * Sites are also pulled in from `private/sites/`.

## Git aliases

<a id="jj"></a>

> [!NOTE]
> I'm almost exclusively using [jj] now, so while the below still represents how I use git, I don't tend to use it directly all that much any more! [Here's a post about jujutsu][miniature]. [`home/fish.nix`](home/fish.nix) includes jj aliases similar to the below, but they're undergoing active refinement as my use increases!

[jj]: https://github.com/martinvonz/jj
[miniature]: https://lottia.net/notes/0013-git-jujutsu-miniature.html

Firstly, for all our git aliases, we [create a shell alias][git alias line] that matches it; i.e. if you have `git c` defined for `commit`, then it's enough to type `c` at the shell instead.

This _isn't_ overkill — I talk a bit about this early in [Nix revisited], but I'd like to elaborate now: Git is a Swiss Army knife. It's way better than what came before it in lots of ways, and I'm sure (and glad) [folks are improving on it][jj], but I'm _very_ comfy with it, and not because I've abstracted it all away from me so I don't have to think about it, but because I brought it close enough that all its little implements (continuing with the SAK analogy) are like my own fingers. Err. Or something.

[git alias line]: https://github.com/kivikakk/vyxos/blob/aed7f16d432f5b0a73268aa34521fed07f24e7c1/home/fish.nix#L23
[Nix revisited]: https://lottia.net/notes/0003-nix-revisited.html
[jj]: https://github.com/martinvonz/jj

Have a look at [`home/git-aliases.nix`](home/git-aliases.nix). Everything's split into groups of related aliases. Remember that these are all promoted to shell aliases in their own right, so (as documented in [Nix revisited]) where necessary I adjust the alias to move out of the way of a common shell utility (like `cp` ~> `pc`). There are some utilities I don't care about and happily displace; that's what [command] and [builtin] are for.

[command]: https://fishshell.com/docs/current/cmds/command.html
[builtin]: https://fishshell.com/docs/current/cmds/builtin.html

* `cl`: `clone`. I pull down a lot of new code! (Don't use this for [multiple working trees][worktree], or multiple remotes.)
* `co`: `checkout`. Something I find myself doing a lot is `co BLAH^ -- x/y/z` if I found I removed `x/y/z` in commit `BLAH` and want to reintroduce it (but I don't want to revert all of `BLAH`). Of course, `co jkl` or `co -` to change branches are the main use.
  * `cb`: `checkout -b`. Branches are extremely lightweight, use them constantly! Use them to slap temporary names on things while you shift things around (so you don't have to hunt in the [reflog], but you always can do that too), to track remotes, all over.
  * `pc`: `checkout -p`. Interactively checkout hunks. I'll do this when I want to get rid of some debugging stuff I don't need any more, often cycling between `pc` and `a` to remove and stage alternately. You can give a path to restrict the scope if you know what you want to revert parts of.
* `s`: `status -sb`. Default to short output, with branch/tracking info. Making the output short is key to ensuring you can call it as freely as `ls` (which I [alias to `.`][dot]!); if it's long, the feeling of loss of context will act as counterpressure, which makes it easy to feel disconnected from the state of your repo/working tree/index.
* `b`: `branch`. Branch ops, but also just to list local branches by itself.
  * `ba`: `branch -a`. Include remotes.
  * `bd`: `branch -d`. Delete a branch.
  * `bdd`: `branch -D`. _Really_ delete a branch. Part of branches being lightweight is not just "easy to create" but "easy to delete" (and recreate again if you need to!). Otherwise they accumulate and become the very opposite.
* `h`: `show`. (`s` was taken, so we go to the second letter.)
  * `h1`: `show HEAD^`.
  * `h2`: `show HEAD^^`.
  * … `h5`: `show HEAD^^^^^`. If I've gotten to this stage I need to find a better point of reference, but they do come in handy for quickly retracing steps.
* `d`: `diff`. Use it often. Consider also `d -w` to ignore whitespace.
  * `dch`: `diff --cached`. Shows the diff between the index (staging area) and HEAD; i.e. what you would commit if you hit `c`.
* `l`: `log --show-notes='*' --abbrev-commit --pretty=format:'%Cred%h %Cgreen(%aD)%Creset -%C(bold red)%d%Creset %s %C(bold blue)<%an>% cm%Creset' --graph`.
  * Yes, really.
  * This is probably one of _the_ most important ones. For the same reason as "short status" above, actually condensing log info into short lines **with the tree structure visible** is super important for having a _feel_ about the shape of your repo and where exactly you're peeking into it from.
  * `la` is the same but with `--all` added; this means you can see remote tracking branches, branches you're not on, etc., which gives an even wider overview.
  * `lp` adds `--patch`, which includes the full diff of each commit between the lines. I'll use this pretty often when looking at where references to certain items have been added and removed over time across a repository; if it's all in one file or subtree, `lp x/y/z` works great too.
* `a`: `add -p`. The default is **always** to use the patch interface to stage hunks incrementally. You want this to be your default. Know what you're committing.
  * Seriously, in a work situation, in a hobby project situation, in a tiny throwaway whatever, **know what you're committing**. You can't accidentally commit a TODO if you look at every line _before_ you put it in a commit.
  * Short on time or motivation? Sure, `ad . && cm blah` and call it a day. Tomorrow you `r HEAD^`, `a` and split it out properly.
  * `ad`: `add`. For when you want to add whole files or directories. `a` is my default, but I still need `ad` because this is a Swiss Army knife, not a nanny.
* `mrm`: `rm`. Because `rm` was taken.
  * `mrc`: `rm --cached`. Remove a file from the index, without touching the working tree; "unstage" a file. You'll need `mrc -f` a fair bit of the time.
* `c`: `commit`. Use this often, since you'll have interactively staged with `a` and want to write a long commit message in `$EDITOR`.
  * `cm`: `commit -m`. More often for quick shots: `cm wip`, `cm fixup`, `cm 'v0.26.0.'`, etc.
  * `cx`: `commit --amend`. You forgot to stage one little hunk of a file? `a && cx`, no wuckas.
  * `pcp`: `cherry-pick`. This is conceptually similar to committing, so I include it here! I use this when I'm doing a drawn-out "manual" rebase, or when I simply have one commit to pull from elsewhere. It's handy to have at hand so you can easily `pcp --abort` if you don't like a conflict.
* `m`: `merge`.
  * `mnf`: `merge --no-ff`. When you're merging something that could be a fast-forward and you don't want it to be; this results in a merge commit like a PR merge on GitHub.
* `r`: `reset`. Use this a lot. By default with no arguments, this "unstages" everything by resetting the index to match HEAD, leaving your working tree untouched. With a commit argument, it resets both the index _and_ the current branch HEAD to the commit given (which can be a branch name or tag), still leaving the working tree untouched. This means you can essentially rewind a branch to a different point in time, without disrupting your work.
  * In other words, a poor man's "squash the last 5 commits" looks like `r HEAD~5 && ad . && c`. (This also includes your working tree at the time of starting, note.)
  * `rh`: `reset --hard`. This is as the above, but also resets the working tree.
  * You like what you did in subdirectory `plant/` as of the current commit, but otherwise you want to drop the last 3 commits, and condense the plant changes? `cb yummy-plant && co - && rh HEAD^^^ && co yummy-plant -- plant/ && bdd yummy-plant && c`. It's free real estate. (You can skip the branch creation and just plonk HEAD's SHA into your clipboard before starting, or even use `HEAD@{n}`!)
* `en`: `revert`. For introducing a revert commit.
* `rb`: `rebase`. Bringing some changes up to date.
  * `ri`: `rebase -i`. For carefully bringing changes up to date, or moreover for rewriting history. Use this to condense commits, drop commits, pull commits apart, anything you so desire.
  * `rbc`: `rebase --continue`. Continue a rebase after editing a commit or addressing conflicts. You might also need `rb --skip` if a commit doesn't result in any change on the new base.
  * `rba`: `rebase --abort`. Rewind all changes made to before you started your last rebase.
* `w`: `push`. The mnemonic is "write".
  * `wf`: `push -f`. If you enjoy revising history as much as I do, you will find this helpful. All the usual nonsense applies: don't rewrite history of branches others are working on unless you have a really good thing going.
  * `wo`: `push origin`. Particularly useful with `wo :xyz` to delete branches and tags on the remote named `origin`.
  * `wu`: `push -u`. Set the local branch to track the remote.
* `v`: `pull`. The mnemonic is "`v` is next to `w` on Dvorak" (:
* `f`: `fetch`.
  * `fa`: `fetch --all`. Fetch all remotes.
* `rv`: `remote -v`. Lists remotes.
  * `ra`: `remote add`. Add a new remote. I do this when fetching a new long-term collaborator's changes, or adding my own fork (or an upstream to my existing fork).
  * `rp`: `remote prune`. Prune a remote; i.e. delete tracking branches that don't exist on it.
  * `rpo`: `remote prune origin`. Prune the `origin` remote.
  * `rpa`: `fetch --all --prune`. Fetches all remotes, pruning them in the process. (The fact that this also fetches is Fine. Fetching is not dangergoose.)
* `st`: `stash`. Stashes all local changes. You can also just make a temporary commit and use reset shenanigans, but stash is often faster, and by default preserves your index and working tree separately. (Try `la` after a stash to see `refs/stash`.)
  * `st -p` is helpful if you want to partially stash some stuff, before committing (and perhaps reverting) some others.
  * `sth`: `stash show -p`. We add `-p` as, by default, `stash show` doesn't actually show you the diff of the stashed change. (The `h` mnemonic is preserved from our top-level `h` alias.)
  * `stl`: `stash list`.
  * `std`: `stash drop`. Drops the latest stash (or stash reference). Note that the commit reference it gives you can be given to `sta` until it's garbage collected, so it's no big deal if you do this by accident.
  * `stp`: `stash pop`. Applies the latest stash (or stash reference), and then drops the stash if it applied without conflict.
  * `sta`: `stash apply`. Applies the latest stash (or argument), but the argument doesn't have to be an explicit stash reference (since it doesn't need to be a valid stash to drop, unlike with `pop`).
* `sms`: `submodule sync --recursive`. Sync submodule remotes with `.gitmodules`.
  * `smu`: `submodule update --init --recursive`. Use this to initially get and update submodules over time.
* `bl`: `blame`.

[worktree]: https://git-scm.com/docs/git-worktree
[reflog]: https://git-scm.com/docs/git-reflog
[dot]: https://github.com/kivikakk/vyxos/blob/aed7f16d432f5b0a73268aa34521fed07f24e7c1/home/fish.nix#L12

## SSH aliases

Similar to above, a [shell alias is created][ssh alias line] for every host defined in `hosts.toml`; i.e. typing `kala` is enough to `ssh kala`.

[ssh alias line]: https://github.com/kivikakk/vyxos/blob/aed7f16d432f5b0a73268aa34521fed07f24e7c1/home/fish.nix#L24

## `vyxnix`

Similar to git, I need the Nix tools closer to hand. [`vyxnix`](https://github.com/kivikakk/vyxos/blob/ee3468c9e365d8cc6cec009bb225a8295925b14f/modules/fish/vyxnix.fish) is the launcher that makes that happen; combine it with [a range of aliases](https://github.com/kivikakk/vyxos/blob/ee3468c9e365d8cc6cec009bb225a8295925b14f/home/fish.nix#L14-L21) and baby you've got yourself a stew.

It mostly documents itself, so I'm going to just repeat the header comments:

```fish
# Principal nix3 launcher.
#
# "develop" and "shell" are treated specially:
# vyxnix develop                  -> nix develop --command fish
# vyxnix develop x y z            -> nix develop x y z --command fish
# vyxnix develop x -- y z         -> nix develop x --command fish -c "y z"
# vyxnix develop x --command y z  -> nix develop x --command y z
# "d/s" below refers to these cases.
#
# "run" is also treated specially:
# vyxnix run xyz                  -> nix run nixpkgs#xyz
# vyxnix run abc#def              -> nix run abc#def
# vyxnix run uvw -- nyonk         -> nix run nixpkgs#uvw -- nyonk
#
# !x=y translates to --override-input x y.
# Default options (specify --vyx-no-defaults to omit):
set -f defaultargs -L --keep-going

# Specify --vyx-dry-run to echo the command that would be executed.
```

In practice this means (modulo the `defaultargs` mentioned above):

* `nd -- make` is equivalent to `nix develop --command fish -c "make"`.
* `nb !nixpkgs=~/g/nixpkgs` is equivalent to `nix build --override-input nixpkgs ~/g/nixpkgs`.
* `nf` is equivalent to `nix fmt`.
* `nr htop` is equivalent to `nix run nixpkgs#htop`.

The default args are also really helpful — I almost never remember to include `-L` or `--keep-going` until a long build has failed and I wish I already had.

The really nice thing about using Fish everywhere, too, is that `vyxnix` and aliases using it all support tab-completion correctly, including the `--vyx` options. If they didn't, I'd want to use them a lot less, and keep forgetting the exact `--vyx` options since they're so rarely wanted.

## `J`

This is like `vyxnix`, but for jj! [`J`](https://github.com/kivikakk/vyxos/blob/4921e89b8b11b86c1f84c3ab0338408a469163ea/home/J.fish) is a simple launcher which makes a few options nearer to hand:

```fish
# !i -> --ignore-immutable
# !b -> --allow-backwards
# !p -> --no-pager
# !ae -> --reset-author --no-edit
```

This allows for scenarios like the following:

```console
$ Aq
Error: Commit 063ff6e65ac0 is immutable
Hint: Pass `--ignore-immutable` or configure the set of immutable commits via `revset-aliases.immutable_heads()`.
$ Aq !i
Working copy now at: vwsmmryz dde83cf9 (empty) (no description set)
Parent commit      : qoqluvpo 4921e89b main* | README: update for jj.
```

[sops-nix]: https://github.com/Mic92/sops-nix
[jambalam]: https://lottia.net/notes/0005-jambalam.html
[extra dependencies]: https://search.nixos.org/options?channel=unstable&show=system.extraDependencies&from=0&size=50&sort=relevance&type=packages&query=system.extraDependencies
[antifuchs]: https://github.com/LnL7/nix-darwin/issues/356
[cowsay]: https://en.wikipedia.org/wiki/Cowsay
[Iosevka]: https://typeof.net/Iosevka/
[ssh_config]: https://man.freebsd.org/cgi/man.cgi?query=ssh_config&sektion=5&manpath=OpenBSD+3.4
[helix]: https://helix-editor.com/
[aerc]: https://aerc-mail.org/
[Comenzar]: https://github.com/kivikakk/comenzar
[furpoll]: https://github.com/kivikakk/furpoll
[502]: https://kala.hrzn.ee
[OpenSMTPD]: https://www.opensmtpd.org/
[`nixos-infect`]: https://github.com/elitak/nixos-infect
[kivikakk.ee]: https://kivikakk.ee
[lottia.net]: https://lottia.net
[eka.kivikakk.ee]: https://eka.kivikakk.ee
[hrzn.ee]: https://hrzn.ee
