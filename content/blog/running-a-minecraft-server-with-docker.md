+++
title = 'Hosting your own Minecraft Server with a Custom Map'
date = 2020-04-12T11:21:26-07:00
draft = false
tags = ["minecraft", "docker"]
description = "Running a Minecraft server for co-op Witchcraft and Wizardy using Docker"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/img/harry_potter.png"
+++


## Is hosting your own minecraft server even a good idea?

Short answer:

> Probably not, but it's fun... kinda

## Some context

So recently a custom minecraft map came out and I wanted to play co-op with my brother,
so being the tech person that I am, I decided to host my own minecraft server. Given my
experience with Docker I chose that as my solution for running the server and Digital
Ocean as my hosting provider.

> By the way, shoutout to the map makers,
> [Witchcraft and Wizardy](https://www.planetminecraft.com/project/harry-potter-adventure-map-3347878/)
> is truly an awesome experience.

![witchcraft](/img/harry_potter.png)

## Getting started (what I won't be covering)

So I'm not going to go over how to get a server from your hosting provider or how to do
things like log in, this is more of a tutorial for users who are experienced enough to
get their own linux server and ssh into it. However most of the things I will go over
will work just as well for Docker for Mac/Windows, albeit having other people connect
will be a bit more difficult.

For a great tutorial on how to do that refer to
[Digital Ocean's own documentation](https://www.digitalocean.com/docs/droplets/how-to/connect-with-ssh/).

I also won't cover installing/setting up Docker. Docker's own documentation is good enough
to get you started with that, but I do recommend using the easy install script
(provided you are on a distribution that is actually supported).

```bash
# Always check the script after you pull it to make
# sure it doesn't do anything bad.
curl -fsSL -o get-docker.sh https://get.docker.com
sh get-docker.sh
```

## Actually making things work

### File Structure (Or How to Stay Organized and Keep Your Sanity)

First things first is to set up a file structure that is organized enough for you to not
lose sanity. This file structure will account for the various `data` folders we will be
mounting into the eventual running minecraft docker containers.

> If things aren't organized, then they won't be easy to maintain later on

For my personal server I use a file structure similar to:

```
${HOME}/
└── minecraft/
    └── witchcraft-and-wizardy/
```

### Loading custom maps

So next thing to do is to put our custom maps into their respective folders.
Little known fact, at least for me, was that the custom maps actually need to
be loaded into the `world` subdirectory.

> I actually spent a long time figuring this out and I think is actually the
> most crucial part of loading a custom map on your minecraft server.

```
${HOME}/
└── minecraft/
    └── witchcraft-and-wizardy/
        └── world/ <------ This folder here
```

For me this involved downloading the `zip` of the map and then running the
following:

```bash
# Create out directories and all parent directories
mkdir -p ${HOME}/minecraft/witchcraft-and-wizardry/world

# Enter the directory we want to unzip to
pushd ${HOME}/minecraft/witchcraft-and-wizardry/world

# Unzip our contents
unzip /path/to/witchcraft-and-wizardy.zip

# Chown our minecraft folder to user 1000
chown -R 1000 ${HOME}/minecraft
```

> **NOTE**: It is **extremely** important to chown your `minecraft` folder to
> 1000 since that's what the minecraft docker image will be running as.

And that's actually it, no need to do anything else.

### Actually running the dang thing

So for today I decided to use the docker image `itzg/docker-minecraft-server`.
The team that maintains it has done an excellent job at making the image easy
to use and the underlying code easy to understand.

To run our original *Witchcraft and Wizardy* server, it should be as
simple as running:
```
docker run \
    -d \
    -p 25565:25565 \
    -e EULA=TRUE \
    -e VERSION=1.13.2 \
    --name mc-witchcraft-and-wizardy \
    -v ${HOME}/minecraft/witchcraft-and-wizardy:/data \
    itzg/minecraft-server
```

What this is doing is it's telling the image to pick out the `1.13.2` version
of the vanilla minecraft server and to volume mount our local data directory
to the data directory inside of the container.

This ensures that if the container ever needs to restart we do not lose our
progress.

And that's it! Really that's it. No need to do anything else.

## Wrapping up

So it's pretty simple to actually go about running your minecraft server in
the cloud! Have fun, I might do a follow up on how to run multiple servers 
with actual domain names, but for right now I'm just having fun playing
`Witchcraft and Wizardry`.

![wicked](https://media.giphy.com/media/VwUquCGtIatGg/giphy.gif)
