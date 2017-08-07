+++
draft = true
date = "2017-08-06T20:35:46-07:00"
tags = ["software"]
title = "Make, the past, present, and future of software development"

+++

# Context

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">This is a diagram of me endlessly leaving, and returning to, GNU make. <a href="https://t.co/osxbbma5Eg">pic.twitter.com/osxbbma5Eg</a></p>&mdash; Kris Jenkins (@krisajenkins) <a href="https://twitter.com/krisajenkins/status/882895918948913156">July 6, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

[GNU Make](https://www.gnu.org/software/make/) is one of those tools
that has been around so long that no one really likes it or
appreciates it anymore. Up until recently I didn't really see the
point in learning it because of the littany of other build tools
available to me.

> But then things changed.

With the start of my job at [Docker](https://docker.com) I started
to work with systems that were not guaranteed to be compatible
with some of the newer build systems that everyone seems to
be jumping to. The only guarantee we had is that the standard
unix tools were there (like GNU Make).

> So it goes

# Makefiles by example:

```makefile
# Run ansible-playbook stuff
DEFAULT_USER?=centos
VENV_DIRECTORY=$(CURDIR)/.venv
ANSIBLE_PLAYBOOK=$(VENV_DIRECTORY)/bin/ansible-playbook

all: python dotfiles neovim zsh docker

.venv:
	if [ ! -d  "$(VENV_DIRECTORY)" ];then \
		virtualenv "$(VENV_DIRECTORY)"; \
	fi
	if [ ! -f "$(ANSIBLE_PLAYBOOK)" ];then \
		$(VENV_DIRECTORY)/bin/pip install ansible; \
	fi

.PHONY: clean
clean:
	$(RM) *.retry

.PHONY: python
python: .venv
	$(ANSIBLE_PLAYBOOK) python.yml -u $(DEFAULT_USER)

.PHONY: dotfiles
dotfiles: .venv
	$(ANSIBLE_PLAYBOOK) dotfiles.yml -u $(DEFAULT_USER)

.PHONY: neovim
neovim: .venv python
	$(ANSIBLE_PLAYBOOK) neovim.yml -u $(DEFAULT_USER)

.PHONY: zsh
zsh: .venv dotfiles
	$(ANSIBLE_PLAYBOOK) zsh.yml -u $(DEFAULT_USER)

.PHONY: docker
docker: .venv
	$(ANSIBLE_PLAYBOOK) docker.yml -u $(DEFAULT_USER)
```

This is a Makefile I wrote recently for personal use. At first,
it can appear complicated. It uses specialized targets like
`.PHONY`, has dependencies for targets, uses `make` variables,
and even uses built-in aliases for `make`. Let's break it down.

