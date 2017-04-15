+++
date = "2017-04-14T15:13:49-05:00"
description = "PUDB and why it's my favorite Python debugger out right now"
tags = ["Python"]
title = "Using PUDB (The ultimate Python TUI debugger)"
author = "Eli Uriegas"
draft = true

+++

Python debuggers (at least to me) starting out as a new Python developer were a
bit of a mystery. Sure there were things like the built in PDB (a practical mirror of GDB)
which have been around since at least
[1992](https://github.com/python/cpython/commit/921c82401b6053ae7dacad5ef9a4bd02bdf8dbf1#diff-0e7502e2c94ec5b34ab974ab31804f34),
but it didn't seem like they fit the bill of what I wanted exactly. For me my debuggers
should come with a few basic criteria for me to work as efficiently as possible.

# My wants in a debugger:
1. Be easy to use from the command line where I run most of my Python related things
2. Provide all important info for me from the start without me having to ask
  * Currently place in the code
  * Variables and their values
3. Have a way to do easy conditional break points
4. Gives me a way to break into a Python shell wherever I want

# A bit of context first
Around the beginning of 2016 I was trying to debug an issue using the aformentioned PDB
to debug my issue. I wasn't very familiar with the code base and it seemed as though
there were a lot of variables associated with the issue so access to the local stack
was very important to me. PDB was performing well at its job but it wasn't like the
awesome debuggers I had used in school to debug C like
[DDD](https://www.gnu.org/software/ddd/). After a while of playing around with PDB, iPDB,
and trying to configure Pycharm's built in debugger I gave up and started searching for
a new solution. In comes PUDB!
