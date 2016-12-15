+++
categories = [
  "misc",
]
date = "2016-12-14T21:11:08-06:00"
title = "zplug from a former oh-my-zsh user"
author = "Eli Uriegas"
authorlink = "http://github.com/seemethere"
draft = false
slug = "zplug-from-a-former-oh-my-zsh-user"
socialsharing = true

+++

# What is zplug?

[zplug](https://github.com/zplug/zplug) is plugin manager for zsh. 
If you've ever used [vim-plug](https://github.com/junegunn/vim-plug) it's 
pretty much the same idea and it's made by the same guy. With it you can 
pull down various git repositories and use them as pluggable items into your
own zsh distribution.

zplug is nice because it's light, has an intuitive interface, and it's 
extremely fast. As a an everyday zsh user, zplug has shrunk my zshrc and 
heavily reduced the amount of headaches I have when it comes to how fast 
my prompt shows up.

# So how do you use it?

## Installation
Installation of zplug is a simple git clone and can be done automatically 
through your zshrc like so:

```zsh
# You can customize where you put it but it's generally recommended that you put in $HOME/.zplug
if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi
```

## Loading plugins
So loading of plugins goes through the actual `zplug` command. You can 
github or other source control sites (much ike vim-plug), load from popular 
frameworks (like oh-my-zsh, prezto, etc.), and you can even choose to load 
from your local.

Here's a few examples from my zshrc:
```zsh
# Async for zsh, used by pure
zplug "mafredri/zsh-async", from:github, defer:0
# Load completion library for those sweet [tab] squares
zplug "lib/completion", from:oh-my-zsh
# Syntax highlighting for commands, load last
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3
# Theme!
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

zplug load
```

You can even automate the installation of the plugins as well with:
```zsh
# Actually install plugins, prompt user input
if ! zplug check --verbose; then
    printf "Install zplug plugins? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
```

## Updating plugins
Updating is as easy as running:
```
$ zplug update
```

# Why is it better than just using oh-my-zsh?
Well if you use your terminal everyday, and spawn hundreds of shell 
sessions, speed matters. I have not done a proper benchmark to see 
but being able to pick and choose specific things that I like from 
oh-my-zsh and only load those things seems to have greatly decreased 
my shell load time. Also knowing what goes into your shell makes it 
that much easier to debug problems when they arise.

zplug also automates most of things you needed to do manually, like 
downloading plugins from github, updating them, and needing to make 
sure they're all in the right spots.

# Conclusion
There's a comparison of zplug to other zsh plugin managers located at 
the [zplug wiki](https://github.com/zplug/zplug/wiki/Migration).

zplug is my daily driver going forward as far zsh plugin managers go. 
It's the one that makes the most sense to me, it's fast, and it is 
extremely extensible. Give it a shot if you're a current oh-my-zsh user, 
it might just make you a zplug believer like me!
