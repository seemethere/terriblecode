+++
title = "Deploying Static Sites With SSL"
date = 2017-09-13T21:32:17-07:00
draft = true
tags = ["Docker", "SSL", "Meta"]
description = "Static sites are easy, but this setup makes it even easier"
hacker_news_id = ""
+++

# Context

SSL is increasingly important in today's web development workflow and no,
personal blogs like this one are not immune to the wave. With knowing that
Google Chrome, the most used web browser, was going to start [flagging
websites](https://security.googleblog.com/2016/09/moving-towards-more-secure-web.html)
that do not have SSL as unsafe, I knew it would be only be a matter of time
before I had to implement SSL support for this blog.

I put it off for a long time but a couple factors (including my blog breaking
due to a [Hugo](http://gohugo.io/) upgrade) ultimately led me to redo the
infrastructure of my [terriblecode](https://terriblecode.com).

> *NOTE*: This blog post does not cover how to setup a server or a domain name with a DNS.
> For a tutorial on that I highly recommend
> [DigitalOcean's documentation](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean)

# The New Criteria

So with the decision to redo the infrastructure, I had to lay a couple of ground
rules:

1. It had to have SSL that was easy to setup
2. It had to use [Docker](https://docker.com)
3. It had to work off of git pushes

# Getting SSL, Easily

With the advent of [letsencrypt](https://letsencrypt.org/), obtaining a
browser trusted certificate is as simple as running an automated script.

> In comes [Caddy](https://caddyserver.com/)

![Caddy Server](https://cloud.githubusercontent.com/assets/1128849/25305033/12916fce-2731-11e7-86ec-580d4d31cb16.png)

Caddy is awesome because its syntax is simple and getting certificates
is as easy as entering an email address.

The blog post your reading right now is served statically by a Caddy Server
that grabbed the SSL certificate on it's own with a literal 4 line
configuration file, a thing I never thought was possible after using other
web servers for so long.

Would you believe that this is the whole configuration file?

```
terriblecode.com {
    tls eliasuriegas@gmail.com
    root /public
}
```

# Dockerizing My Infrastructure

![Moby Dock](https://i1.wp.com/blog.docker.com/wp-content/uploads/0ca21ece-c73d-46d9-bd02-a0f1dd3cf042.jpg?resize=425%2C365&ssl=1)

So I've been using Hugo as my static site generator for over a year. I've
been ecstatic with the results but I've never liked the idea of having to
install the binary locally (which ultimately led to me breaking my
blog a few weeks ago) and have always felt like there was a better
way to do it.

I found a few Hugo images on Docker Hub already but they were too big in
size for my tastes and I thought I could slim down the Docker image.
I utilized [multi-stage Docker builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/)
to [build an image](https://hub.docker.com/r/seemethere/hugo-docker/tags/)
that was **25x** smaller than the most popular Hugo image available on Docker Hub!

For implementation on this portion please take a look at the Github
repository for [hugo-docker](https://github.com/seemethere/hugo-docker).

For those asking, I also tried this with Caddy but could not achieve the
same result due to `ca-certificates` needing to be installed for SSL to
function correctly. I eventually settled on
[abiosoft/caddy](https://hub.docker.com/r/abiosoft/caddy/) as my Caddy image.

# Deploying with Docker


## Generating the site

So for static sites it's fairly simple to generate a site, using my image you
can generate site like so (from a Makefile in the root directory of your site):

**/build/Makefile**
```Makefile
public:
	docker run --rm -v "$(CURDIR)":/v -w /v seemethere/hugo-docker
```

> *NOTE*: You may need a primer on [`docker run`](https://docs.docker.com/engine/reference/commandline/run/)
> if you are not familiar with this syntax.

I generate the public directory using the Docker image I showed before,
and the utilize `rsync` to update any changed files to a `/public`
directory at the root of the file system.

**/infra/Makefile**
```Makefile
/build/public:
	$(MAKE) -C /build public

/public: /build/public
	mkdir -p /public
	rsync -a -v /build/public
```

## Serving the site

Serving the site is fairly simple once you generate the static pages.

For this I have another couple of Makefile targets:

**/infra/Makefile**
```Makefile
.PHONY: run-caddy
run-caddy:
	docker run \
		--name "$(CADDY_NAME)" \
		--restart always \
		-v /infra/Caddyfile:/etc/Caddyfile \
		-v /root/.caddy:/root/.caddy \
		-v /public:/public \
		-p 80:80 \
		-p 443:443 \
		-d \
		abiosoft/caddy

.PHONY: relaunch-caddy
relaunch-caddy:
	docker kill $(CADDY_NAME)
	docker rm $(CADDY_NAME)
	$(MAKE) -C /infra run-caddy
```

The basic idea behind these targets is to:

* Start a container with a name `--name "$(CADDY_NAME)"`
* Volume mount my specific directories:
  * For my Caddyfile `-v /infra/Caddyfile:/etc/Caddyfile`
  * For storing certs `-v /root/.caddy:/root/.caddy`
  * For my static site `-v /public:/public`
* Expose ports necessary to serve the site (`80` and `443`)
* Let the container run in the background `-d`

I also have a Makefile target to re-launch the container but the only
changes needed to update the site itself can be done by updating the
files in `/public`.

# Using Git Hooks to Deploy Changes

So far we've talked about how to get certificates and how to build and
deploy infrastructure using Docker, but what about pushing changes up?

What if deploying your static site could be as simple as:

```
git push live
```

## Getting to `git push live`

> *NOTE*: [A primer on Git hooks may be needed](https://git-scm.com/book/gr/v2/Customizing-Git-Git-Hooks)

So all of the magic of being able to do a `git push live` is located in a file
called `post-recieve`. Basically what git does is run `post-recieve` as a shell
file after receiving files through a `git push`.

For our scenario we'll assume that after a push we want three things to happen:

1. Rebuild our static site
* Deploy our static site to the `/public` directory (if the rebuild passes)
* Launch a container that serves `/public` to the outside world with SSL
  * noop if the container is already running

The `post-receive` script for terriblecode.com looks like:

**/root/terriblecode.git/hooks/post-recieve**
```bash
#!/usr/bin/env bash

set -e

CADDY_CONTAINER_NAME=$(make -C /infra print-CADDY_NAME)

# Generate hugo docker image, clean out old versions
make -C /infra clean-hugo-image hugo-image

# Build static site in public directory, clean out old build directory
make -C /infra clean /public

# Run the container if it's not already running
# container restarts should be handled manually
if ! docker ps -a | grep "$CADDY_CONTAINER_NAME" >/dev/null; then
	make -C /infra run-caddy
fi
```

Some of the Makefile targets might look familiar from the past sections! It's always
to use Makefiles to break down problems into bite sized chunks so that even if one fails
it's always fairly simple to debug and re-run locally.

# Closing thoughts

All in all the transition took about 2 nights worth of hair pulling to complete from
building out the infrastructure to actual deploying the website with the certificates.
Coming out of the transition I learned a few thoughts:

* Docker makes it easy to deploy this type of site on any Linux distribution that is supported by Docker
* Caddy makes it extremely easy to get certificates and serve static sites
* I wish more people knew how Makefiles worked so mine wouldn't look so much like magic

Tweet me [@\_seemethere](https://twitter.com/\_seemethere) if you have any
questions regarding this blog post, if you really liked the blog post, or if
you're needing help setting your own blog!
