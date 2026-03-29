+++
title = 'Publishing a Python Package with Poetry'
date = 2019-11-14T13:39:54-08:00
draft = true
tags = ["python", "packaging"]
description = "Publishing Python packages use to be like pulling teeth but thanks to a new tool it's easy and even enjoyable."

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

# Context

Publishing a Python package, for me, has been such a pain that I actually
chose to write off Python for the most part as a language all together. In the
past the ecosystem has been so fragemented between `twine`, `setuptools`,
`distutils`, etc. that it was a headache figuring out which tool to use.
Well not anymore, I'm happy to say that I've discovered a tool that is both
easy to use for not only publishing but overall development.

> Enter, [`poetry`](https://github.com/sdispater/poetry).

# Initializing a project

Initializing a project with `poetry` is pretty simple:

```
poetry init
```

This will create a `pyproject.toml` inside the base of your project which will
contain all of your dependencies and metadata about your project.

The major plus of this `pyproject.toml` is that you don't have to write a
a confusing `setup.py` anymore. There's no finicky syntax to do half implemented
hacks to allow for the `setup.py` to work on different systems. It's simple,
opinionated, and great because there's no space for interpretation. For more
reading on `pyproject.toml` check out
[PEP 518](https://www.python.org/dev/peps/pep-0518/).

# Managing dependencies

No more need to specify dependencies in a requirements.txt you can add dependencies
using the following:

```
poetry add <dependency>
```

It's simple to update dependencies at that point as well with:

```
poetry update
```

After that you'll get a generated `poetry.lock` which will contain all of
the dependencies and versions associated with making your project work.

# Publishing

After finalizing a version of your package, publishing the package to PyPI is as
simple as:

```
poetry publish
```

And that's basically it.

No really, it's that simple.
