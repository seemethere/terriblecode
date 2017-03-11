+++
title = "Why ptpython is the only REPL you will ever need"
description = "An overview of ptpython"
tags = [ "python", "ptpython" ]
categories = [
  "python",
]
date = "2016-12-13T22:15:12-06:00"
slug = "why-ptpython-is-the-only-repl-you-will-ever-need"
draft = false

+++

# Some backstory
For a few months when I first started developing with python I was using [ipython](https://github.com/ipython/ipython) for all of my REPL needs for python. At the time nothing really competed with ipython.

However I had a few gripes:

  * Multiline editing and history was non-existent (If you defined a function, good luck re-editing it)
  * Auto-completion didn't function like most text editors do, with completion showing a pop-up of all available options
  * Pulling code in the REPL into a text editor was spotty at best

So imagine my surprise when I found a little python REPL named [ptpython](https://github.com/jonathanslenders/ptpython) courtesy of reddit's own [/r/python](https://www.reddit.com/r/Python/comments/2tocz7/ptpython_a_better_python_repl/)

I am gonna go over some of my favorite features of ptpython and why it is my daily driver for all of my python REPL needs.

# Features

## Multiline Editing
<script type="text/javascript" src="https://asciinema.org/a/2vl7a7qrday6tfrkzboaq484x.js" id="asciicast-2vl7a7qrday6tfrkzboaq484x" async></script>

This is the first feature that really drew me to ptpython. The ability to edit multiple lines is a feature so good it'll make you wonder why no other interpreter had done it before.

## History Browser
<script type="text/javascript" src="https://asciinema.org/a/6zdt7tfw72al4fits7kcst4js.js" id="asciicast-6zdt7tfw72al4fits7kcst4js" async></script>

The history browser is a killer feature that I use everyday. It can be used to pick and choose code you have entered before to include into your current session. It is also searchable and, with recent updates, is very fast.

## Autocompletion and Documentation Popups
<script type="text/javascript" src="https://asciinema.org/a/8ehkdjy5tk1rqep441vxh9pcw.js" id="asciicast-8ehkdjy5tk1rqep441vxh9pcw" async></script>

This is another killer feature which I don't think I could live without now. The idea behind popup autocompletion is amazing. It allows you to see all of your options without you having to hit >TAB multiple times.

## Editor integration
<script type="text/javascript" src="https://asciinema.org/a/6d1klx0p3uc8gg4aknqdmcyqi.js" id="asciicast-6d1klx0p3uc8gg4aknqdmcyqi" async></script>

Ptpython allows you to pull code from the interpreter into your own $EDITOR and then put it back into the interpreter without altering all too much in between. It's really an intuitive process and makes code that is a little hard to edit in the interpreter, that much easier to bring into a real text editor like VIM.

# Summary
Ptpython is great, it really is. The people who made it really care about having features that positively affect your workflow and they try to make it easy to for you to get things done quicker.

Some features that I didn't go over here but that are awesome in their own right:

  * Custom keybinds
    * For example I have a keybind to import a statement that allows logging to the terminal.
  * Different colorschemes!
  * Auto-suggestion
  * Complete while typing

Oh it also includes a `ptipython` mode so if you need any of ipython's features you can use that as well! The best of both worlds!

<blockquote class="reddit-card" data-card-created="1470684530"><a href="https://www.reddit.com/r/Python/comments/4wcsvq/why_ptpython_is_the_only_repl_you_will_ever_need/?ref=share&ref_source=embed">Why ptpython is the only REPL you will ever need</a> from <a href="http://www.reddit.com/r/Python">Python</a></blockquote>
<script async src="//embed.redditmedia.com/widgets/platform.js" charset="UTF-8"></script>
