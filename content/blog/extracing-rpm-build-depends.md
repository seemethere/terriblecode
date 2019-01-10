+++
title = 'Extracing RPM Build Dependencies From RPM Spec Files'
date = 2019-01-10T19:47:19-08:00
draft = false
tags = ["rpm", "packaging"]
description = "Extracting and installing build dependencies is a pain, make it easier on yourself with this one simple trick"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

# Specifying build dependencies for RPM packages

Build dependencies in an RPM spec are denoted by `BuildRequires: ${DEPENDENCY}`.

You'll typically find a random spec file with dependencies like this:
```config
Name: foo

BuildRequires: make
BuildRequires: bar

# We're running something on a SuSE distribution
%if 0%{?suse_version}
BuildRequires: suse-specific-stuff
%else
BuildRequires: not-on-suse
%endif
```

# The normal way to extract dependencies

So for every tutorial that you see to build an RPM package one tool stands
above all the rest when it comes to extract / install build dependencies:

```
$ yum-builddep
```

## But how do you run it?

```
$ yum-builddep -y ${SPEC_FILE}
```

## Okay that was too easy, why even write a blog post about this?

Well, my traveler, for all the good that `yum-builddep` does, it has the
most common flaw of them all: **it's not available everywhere**.

For a tool as good as it is, the reliance on underlying package managers
like `yum` make it basically unusable on distributions that do not have
`yum` installed as their package manager.

Notable examples of distributions that do not have `yum` as their package
manager are `fedora` and anything built by `SuSE`.

### So what's the solution on Fedora?

Fedora was fairly easy to solve for, since they're fairly close to RedHat
they have tooling that is comparable with `yum-builddep` in the form of:

```
$ dnf builddep
```

Usage is pretty much the same so if you were writing a script to handle both
you'd probably write something fairly similar to:

```bash
#!/usr/bin/env bash

SPEC_FILE=$1

dep_install=""
if dnf builddep --version >/dev/null 2>/dev/null; then
    dep_install='dnf builddep'
elif yum-builddep --version >/dev/null 2>/dev/null; then
    dep_install='yum-builddep'
fi

${dep_install} -y "${SPEC_FILE}"
```

### But what about SuSE based distributions?

Well this is where it gets a bit tricky.

SuSE doesn't really have a concept of a `builddep` tool and when I asked around
about a potential tool that could work I was pointed in the direction of
installing yum on my `SuSE` build box and then copying the repositories over
to the yum specific `/etc` directory.

A common solution one might try if their spec file is relatively simple would
be something like, searching the file for lines with `BuildRequires` and then
taking those requirements and piping them into xargs as an argument for
package installation.

That'd probably look something like:

```
$ zypper -n install $(grep BuildRequires ${SPEC_FILE} | cut -d' ' -f2 | xargs)
```

Something like this is pretty easy to maintain and understand and doesn't really
require any esoteric tooling, but it's relatively incomplete and doesn't cover
use cases outside of the simplest use case (which in my case has never
actually been the use case).


#### But what about if / else statements and RPM macros?

Well as I've said before, most distributions are different and in being different
they require different dependencies. In the example SPEC file I gave above we can
clearly see that for `SuSE` based distributions one of the build requirements we
have is different than every other distribution we build for.

If we did our simple grep approach our command would look something like:

```
$ zypper -n install make bar suse-specific-stuff not-on-suse
```

Obviously this errors out because the `not-on-suse` dependency isn't on our our
`SuSE` based distribution and in a script we wouldn't be able to omit that
dependency without a special case.

> mfw things don't work on every distribution I build for

![why](https://media.giphy.com/media/3oz8xMbKLAkRLHYNgI/giphy.gif)

## A solution that works everywhere

Evaluating an RPM specification without actually executing anything is surprisingly
difficult. Common knowledge dictates that to build an RPM spec one would use
`rpmbuild` like so:

```
$ rpmbuild -ba ${SPEC_FILE}
```

But what command do you execute if you just want to see what the SPEC file
looks like if you expanded all the macros?

### Introducing `rpmspec`

`rpmspec` is a tool that's been around forever but wasn't really known to me until
after I started to try to solve this issue we had.

Usage of `rpmspec` for our exact use case is:
```
$ rpmspec --parse ${SPEC_FILE}
```

This will parse our spec file, expand all the macros (like if/else statements) and
output the resulting spec file to stdout (which we can then do our `grep` on!)

Our resulting command looks something like:
```
$ zypper -n install \
    $(rpmspec --parse ${SPEC_FILE} | grep BuildRequires | cut -d' ' -f2 | xargs)
```

### How about for everything else?

Unsurprisingly this also works for other distributions to gather build
dependencies, so you can write a simple script like so to cover all
of your bases:

```bash
#!/usr/bin/env bash

SPEC_FILE=$1
NO_OUTPUT='>/dev/null 2>/dev/null'

pkg_manager='yum -y'
if zypper --version ${NO_OUTPUT}; then
    pkg_manager="zypper -n"
elif dnf --version ${NO_OUTPUT}; then
    pkg_manager="dnf -y"
fi

${pkg_manager} install \
    $(rpmspec -P ${SPEC_FILE} | grep BuildRequires | cut -d' ' -f2 | xargs)
```

The solution isn't exactly pretty but it'll work pretty much anywhere!

Have any questions? ping me over at [@\_seemethere
](https://twitter.com/_seemethere)
