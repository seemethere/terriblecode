+++
title = 'How Docker Images Work: Union File Systems for Dummies'
date = 2018-07-18T19:32:09-07:00
draft = true
tags = ["docker"]
description = ""

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

![magic](https://media.giphy.com/media/ujUdrdpX7Ok5W/giphy.gif)

A lot of things about Docker are *mysterious*. Even with an inside view Docker
internals are foreign. We take for granted the systems that were built before,
not intentionally, but in order to promote progress. However I decided enough
was enough and I was going to learn about this technology that I help release
almost every single day.

The first thing that jumped out to me was the idea of the Union File System
that enables Docker's efficient storage of image layers. This post is basically
my interpretation of what these concepts are and hopefully a simpler
explanation since the ones that I read were a little bit over my head.

# WTF is a Union File System?

From [wikipedia](https://en.wikipedia.org/wiki/UnionFS):

```text
Unionfs is a filesystem service for Linux, FreeBSD and NetBSD which implements
a union mount for other file systems. It allows files and directories of
separate file systems, known as branches, to be transparently overlaid,
forming a single coherent file system. Contents of directories which have the
same path within the merged branches will be seen together in a single merged
directory, within the new, virtual filesystem.
```

For people who aren't so great with words, Union File Systems basically allow
you to take different file systems and create a union of their contents with
the top most layer superseding any similar files found in the file systems.

For this blog post I'm going to be focusing on the `overlay(fs)` since it's
the recommended storage driver currently for Docker (as of 18.06.0-ce).

# So How Does it Work? (With a metaphor)

* TODO: Fill this section out with a better metaphor

# So How Does it Work? (Under the hood)

## Layers Involved

So basically with the `overlay(fs)`, and more specifically the `overlay2`
storage driver, 4 directories must exist beforehand:

* Base Layer _(Read Only)_
* Overlay Layer _(Main User View)_
* Diff Layer

## Base Layer

This is where the base files for your file system are stored, this layer (
from the overlay view) is read only. If you want to think about this in terms
of Docker images you can think of this layer as your base image.

## Overlay Layer 

The Overlay layer is where the user operates, it initially offers a view of
the base layer and gives the user the ability to interact with files and even
"write" to them! When you write to this layer changes are stored in our next
layer.

When changes are made this layer will offer a _union_ view of the Base and Diff
layer with the Diff layer's files superseding the Base layer's.

Again if you want to think about this in terms of Docker images you can think
of this layer as the layer you see whenever you run a container.

**Disclaimer**: I know some people are groaning right now because I'm
over-simplifying the last statement but please bear with me.

## Diff Layer

Any changes made in the Overlay Layer are automatically stored in this layer.

So right now you're probably thinking, but what if you made changes to
something that's already found in the base layer? Well worry not some smart
person a while ago thought about this as well!

Whenever you write to something that's already found in the base layer the
`overlay(fs)` will copy the file over to the Diff Layer and then make the
modifcations you just tried to write. This type of operation is known as a
`copy-on-write` operation and is probably the most important part of making a
Union File System function correctly.

## Maybe an image would help?

![overlay1](/img/overlay1.png)

In the above image the right pane is the view of the overlayed file layers with
the top right being the base layer and the bottom right being the diff layer.

As you can see `foundation/file1` exists in both the base and diff layer but
the diff layer's file is used instead as it is the higher layer.

I also created another file named `fruit/pear` and we can see that it only
exists in the diff layer.

# So how does this relate back to Docker Images?

* TODO: Add a relation back to docker images
  * Docker Image Layers are just diff layers stacked on top of each other
