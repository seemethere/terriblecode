+++
title = "Developing on a remote instance"
date = 2018-06-28T16:18:09-04:00
meta_img = "/images/image.jpg"
tags = ["productivity"]
description = "Moving my development workflow from my local workstation to one in the cloud!"
hacker_news_id = ""
+++

Have you ever been in a meeting that you didn't really want to be included in?
So you're working and go to compile something and all of a sudden all 3 billion
of your laptop's fans start to fire at full speed. Everyone in the room
suddenly looks at you and now they all know you weren't paying attention

> What if there was a way to run things without having your laptop sound like
> it just started its jet engines?

# Allow me to introduce you to the cloud

![the cloud](https://www.explainxkcd.com/wiki/images/2/28/the_cloud.png)

So when I started working at [docker](https://docker.com) I was given access
to launch instances on EC2 so decided from my first day that I would do most
of my dev work on a remote instance.

A TL;DR of this post is:
* `tmux` is awesome
* `(neo)vim` is the best
* `ssh-agent` forwarding is essential for remote instance working
* `fedora` has great package maintainers

# Learning to love `tmux`

![tmux setup](/img/tmux.png)

So for a long time I had resisted the idea of setting up `tmux`. A lot of my colleauges had told
me it was great but they I didn't really see a need since I developed almost exclusively on
my laptop. It wasn't until I started using a remote instance for development that I realized
how awesome `tmux` actually was.

If you'd like to view my `tmux.conf` you can view it on [github](https://github.com/seemethere/dotfiles)!

Here are the things that have made `tmux` great for my workflow:

### Long standing sessions are *sick*
Having the ability to detach from a session and come back is amazing.
You can also actually save session states so you can reboot your machine and you don't lose your session

### Panes are *amazing*
`tmux` panes are great, being able to split my terminal with `<prefix>,|` or `<prefix>,-` is literally magic

### Copy mode is *great*
You enter copy mode by entering `<prefix>,[` and it's one of my personal favorite features.
You can navigate your terminal using `vi`-like keybindings and copy things into a buffer to copy
and paste anywhere (even in `(neo)vim`!) using `<prefix>,]`.

# `(neo)vim` edits all the things!

I'm not going to go into editor wars here but for my personal setup, `(neo)vim` is my daily
driver. From writing `go` to `Makefiles` to `shell` or really anything, `(neo)vim` does
everything I need.

I won't go deep into details about my setup but I'll give you an idea of some of my favorite
things:

### [Shougo/deoplete](https://github.com/Shougo/deoplete.nvim)
Autocompletion that really just works. It'll match things you already have in your file
and if you have an omni-complete function setup it'll do things like autocomplete `python`
packages, autocomplete `go`, and completion for things in your file-system as well.

### [tpope/vim-surround](https://github.com/tpope/vim-surround)
> Question: Why isn't this already part of the standard `(neo)vim` distribution?

This is absolutely one of the essential plugins I use. I *would not* be able to function
without this plugin. I repeat: I **would not** be able to function without this plugin.

Funnily enough, most `vim` emulation modes for popular editors have this feature baked in. `¯\_(ツ)_/¯`

### [function! StripTrailingWhitespace](https://github.com/seemethere/dotfiles/blob/7ef66a4b34a4404e2c6eb2d43b8812aa715d42e2/vim/nvimrc#L342-L354)

```vim
    function! StripTrailingWhitespace()
        let l:_s=@/
        let l:l = line('.')
        let l:c = line('.')
        %s/\s\+$//e
        let @/=l:_s
        call cursor(l:l, l:c)
    endfunction
    " Deletes trailing whitespace
    nnoremap <Leader>sw :call StripTrailingWhitespace()<CR>
    autocmd vimrc FileType c,cpp,java,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql,groovy,sh autocmd BufWritePre <buffer> :call StripTrailingWhitespace()
```

Have you ever looked at a `git diff` and the diff looked like this:

```diff
diff --git a/1 b/1
index ce01362..1eb3f1d 100644
--- a/1
+++ b/1
@@ -1 +1 @@
-hello
+hello
```

Well what the real diff is, is that I added extra trailing whitespaces, which if we were using
my `StripTrailingWhitespace` function would automatically be stripped away on save. Save a life
and strip your trailing whitespaces please.

**NOTE**: I stole this function from the great maintainers at [amix/vimrc](https://github.com/amix/vimrc)

# `ssh` tricks and tips

#### You should setup an `~/.ssh/config`

These are amazing and allow you to do simple aliases like:

```
$ ssh pet
```

A great primer for this is [Simplify Your Life with an SSH Config File](https://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file)

#### *Do not* store your private keys on your remote instance

Use `ssh-agent` forwarding and you won't cry yourself to sleep when your pet instance gets reaped
by your friendly neighborhood instance reaper and all of your private keys are lost.

Also if your instance gets comprimised it's better that you don't have any actual keys on the
system to minimize import.

*disclaimer*: I'm not a security expert

# Operating system choice

## Turning away from `Ubuntu`

When I started my job at [docker](https://docker.com), I originally spun up a machine with
Ubuntu 16.04 LTS because I had used Ubuntu previously in college and that's what most of
of our developers used as well. It was actually great while I was using it, support for
Ubuntu is widespread since a lot of people use it in production but packages from the main
repository always left a lot to be desired.

For example, installing `git` through the main repository gives you `git version 2.7.4`.
As of writing this, the latest `git` version available is `git version 2.18.0`. To account
for this lag, a maintaners group has gotten together and actively maintains a separate
[ppa](https://launchpad.net/~git-core/+archive/ubuntu/ppa) repository.

Now I don't really blame Canonical for not having up to date packages since most people
running production software on Ubuntu value the stability of a slow moving package repository,
but for my development machines I'd rather be the most up to date

Also, it was a major PITA to compile `tmux` from source on Ubuntu (which I did for every release),
since the latest version found on the main repository doesn't have all the features I need
to run my setup correctly. Also I was compiling `(neo)vim` from source as well since the ppa for
Ubuntu doesn't seem to be updated very quickly.

## Turning towards `Fedora`

Let me start this by saying the Fedora package maintainers are *amazing*.

As someone who works as a release engineer it amazes me how on top of everything the Fedora
package maintainers are. Getting packages out usually within a week of a release is nothing
short of awesome and they should really be commended for all of the hard work they do in
order to keep everyone up to date.

Installing things on Fedora is a breeze, `dnf` is a great package manager, and I don't have
to compile my stuff from source anymore because there's already packages up for them.

I wouldn't run production servers on Fedora, but as far as my development OS goes it has
gotten my vote.

# How can you get started?
Well first and foremost you can spin up an instance on a cloud provider that's
a bit more developer/first timer friendly like DigitalOcean for something as
cheap as [$5 a month](https://www.digitalocean.com/pricing/), which is how I run
this site!

After that you can see my personal setup on 
[github](https://github.com/seemethere/dotfiles). I wouldn't suggest a *1:1*
copy over but you should use it as inspiration on how to start your own.

And then just start developing! When it gets hard, and yes it will get hard to
move from a GUI based environment to a terminal based environment, just keep
going! The more you practice with it the better you'll get and before you know
it you'll be surprising yourself with how much you know.

Have any questions? ping me over at [@\_seemethere](https://twitter.com/_seemethere)
