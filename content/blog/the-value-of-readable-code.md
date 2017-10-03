+++
title = "The Value of Readable Code"
date = 2017-10-02T19:18:34-07:00
draft = true
tags = ["programming"]
description = "There's a real dollar value to having readable code"
+++

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Do yourself, your team, your organization, your contributors, a favor--use automatic code (re-)formatting.<br><br>You&#39;ll thank me later.<br>😊👍</p>&mdash; ꙮ (@viktorklang) <a href="https://twitter.com/viktorklang/status/820175125534412800?ref_src=twsrc%5Etfw">January 14, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

# A bit of background

So at the beginning of the 2017 I submitted a PR comment that looked similar to this:

> Hey guys! Was reading through your code base and found a bit of mixed indentation.
> It's a bit difficult to read so here are some of the key combos to have your IDE
> automatically do it for you.

This comment, while seemingly innocent to me, was met with accusations of my knowledge
of how `git` works, of the value of *working* code, and how much I knew as a developer.
It was strange to see people so seemingly bent out of shape about something as simple
as formatting. The experience of this eventually had me thinking though:

> Is properly formatted code valuable?

# What does improperly formatted code look like?

So imagine you are in a brand new code base: you've cloned the repository, you've opened
up your favorite `EDITOR`, and you're trying to noodle your way around the code when you
come across a function that looks like this:

So on an IDE like IntelliJ the code could end up looking something like this:

<!--TODO: insert photo of intellij with above code-->

But on Github, or other editors (like `vim`) the code looks like:
```java
    public void unregister(Class<?> cls) {
        unregisterSubs(cls);
        for (Method method : cls.getMethods()) {
            if (method.isAnnotationPresent(CMD.class)) {
				CMD c = method.getAnnotation(CMD.class);
				CCommand cmd = commandMap.get(c.command());
				// Actually remove all commands plus their aliases
				try {
					Object i = getPrivateField(plugin.getServer().getPluginManager(), "commandMap");
                    SimpleCommandMap cmap = (SimpleCommandMap) i;
                    Object o = getPrivateField(cmap, "knownCommands");
                    @SuppressWarnings("unchecked")
                    HashMap<String, Command> knownCommands = (HashMap<String, Command>) o;
                    knownCommands.remove(cmd.getName());
                    for (String alias : cmd.getAliases())
                        if (knownCommands.containsKey(alias))
                        	knownCommands.remove(alias);
				} catch (Exception e) {
					e.printStackTrace();
					return;
				}
                commandMap.remove(c.command());
            }
        }
    }
```

But for some editors, including Github the code will look like a jumbled mess.

The code works, but is it readable? As software engineers we write code, not for
the machine but for other humans to be able to read and understand our logic.
Improperly formatted code like the snippet above impedes that process and leads
to minutes and maybe even hours of confusion over what your code actually does.

> Moral of the story being that time equals money, and the more time I have to
> spend reading your code, the more money the company wastes in lost productivity.

# So how do we solve for improperly formatted code?

Languages like `Go` and `Python` are opinionated on their formatting and have
tooling to assist developers in keeping a uniform format throughout their codebases.
Other languages like `C` and `Java` are assisted through IDEs like `Eclipse`,
`IntelliJ`, and `CLion` that make formatting as simple as a keybind.

However for some languages like `bash`, tools didn't exist for checking inconsistent
formatting. I recently submitted a pull request to a popular open source project that
had inconsistent formatting within their own `bash` scripts which led to the creation
of a mixed indentation linter called [misto](https://github.com/seemethere/misto).

Finding mixed indentation in your files can now be as easy as:

```shell
misto $(find . -name "*.sh")
```

# Moving forward

So for now, as software developers we should preserve what makes things easier for us.
Take the low hanging fruit like formatting and make sure that the next person who has
to read the code that you wrote doesn't need to spend more time than they need to.

> Be the change you wish to see in the world

If you'd like to contribute, or have a feature request for `misto` make sure to open
an issue at the Github repository.

> https://github.com/seemethere/misto

Follow me on Twitter for the occassional rant on tech stuff, or for the next Docker CE release!

> [@\_seemethere](https://twitter.com/\_seemethere)
