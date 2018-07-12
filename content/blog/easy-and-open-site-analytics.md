+++
title = 'Easy and Open Website Analytics with Fathom and Docker'
date = 2018-07-11T09:44:08-07:00
meta_img = "/img/fathom.png"
tags = ["infra", "docker"]
description = "Is Google Analytics too complicated for you? Use something open source and free like Fathom!"
hacker_news_id = "17510667"
lobsters_id = ""
+++

![why](https://media.giphy.com/media/kEY1upmMn0DVC/giphy.gif)

# Some context first

I've been using Google Analytics to track traffic for [terriblecode
](https://terriblecode.com) for the better part of 2 years and it's been an
*alright experience*.

Google Analytics has got real time analytics, it'll tell you
how much your page is worth (*$$*), and it'll even do nice things like provide
graphs etc. But honestly, Google Analytics has always felt like a bear, with a
UI that rivals AWS' console for usability. Also, when you're using a Google
product that is free to use you can almost be certain that Google is using your
data somewhere, which doesn't always sit right with me.

So for me, I've been looking out for something that I can:

* Host myself so that I own my data
* Have a simple dashboard
* Contribute to the upstream source

So with that in mind, and the fact that I'm beginning to like running my own
infra, I decided to not [let my dreams be dreams
](https://media.giphy.com/media/GcSqyYa2aF8dy/giphy.gif) and started a search
for a better solution.

# Can you *Fathom* a project like that?


[Fathom](https://usefathom.com/) is dead simple site analytics tool that's
open source that you can deploy onto your own infra! It's built using `go`
and and `javascript` and it's source code is available right now on
[Github](https://github.com/usefathom/fathom).

Fathom has got a really nice and clean interface, and is uncomplicated to
get working with my current setup for [this website
](https://github.com/mtn/cocoa-eh-hugo-theme/pull/97). It's also not a pain
in the butt to deploy and the source code is simple enough to contribute
back to if you so desire.

Overall it's a promising project and one that I was extremely excited to
deploy when I first came to know about it.

## What does it look like?

![fathom](/img/fathom.png)

> *Fathom dashboard for https://terriblecode.com!*

## How to deploy?

So my current setup uses `docker-compose` to deploy, here's a snippet of what
my `docker-compose.yml` looks like:

**NOTE**: This setup uses `mysql` for its db

### `docker-compose.yml`
```yaml
version: '3'

services:
    fathom:
        build:
            context: ./fathom
        restart: always
        environment:
            - "FATHOM_DATABASE_DRIVER=mysql"
            - "FATHOM_DATABASE_NAME=fathom"
            - "FATHOM_DATABASE_USER=fathom"
            - "FATHOM_DATABASE_PASSWORD"
            - "FATHOM_DATABASE_HOST=fathomdb:3306"
        ports:
            - "127.0.0.1:8080:8080"
        links:
            - "fathomdb:fathomdb"
        depends_on:
            - fathomdb

    fathomdb:
        image: "mysql:5"
        volumes:
            - "/var/lib/fathomdb:/var/lib/mysql"
        ports:
            - "127.0.0.1:3306:3306"
        environment:
            - "MYSQL_ALLOW_EMPTY_PASSWORD=false"
            - "MYSQL_DATABASE=fathom"
            - "MYSQL_PASSWORD"
            - "MYSQL_ROOT_PASSWORD"
            - "MYSQL_USER=fathom"
```

**NOTE**: The `FATHOM_DATABASE_PASSWORD` and `MYSQL_PASSWORD` are defined in
a separate `.env` file.

Unfortunately it isn't possible to add users to your `fathom` application
without invoking the `fathom register` command from the CLI, so to get
around that I build my own Docker image with my own user like so:

### `fathom/entrypoint.sh`

```bash
#!/bin/bash

# Register my user
(
    # || true because fathom register will fail out
    # if the user is already created
    ./fathom register \
        --email="myemail@domain.com" \
        --password="reallystrongpassword" || true
)

exec "$@"
```

### `fathom/Dockerfile`

```dockerfile
FROM usefathom/fathom:latest

COPY entrypoint.sh .
CMD [ "./fathom", "server" ]
ENTRYPOINT [ "./entrypoint.sh" ]
```

After all of that, deployment is as simple as:
```
$ docker-compose up -d fathom
```

`fathom` has its own ways to register HTTPS for the application but I'd
personally recommend something like [Caddy](https://caddyserver.com/)
which I cover in another blog post of mine about [serving static sites
with HTTPS](/blog/deploying-static-sites-with-docker-and-ssl/).

# Closing thoughts

Google Analytics is a good tool and it's definitely worth it if you're a bigger
entity trying to collect actionable data about what to post on your webiste
next. But if you're like me, and you just want to check in every now and then
to see how things are doing then `fathom` is most likely the best choice for
you.

Have any questions? ping me over at [@\_seemethere
](https://twitter.com/_seemethere)

![do it](https://media.giphy.com/media/jndc0TQq9fvK8/giphy.gif)
