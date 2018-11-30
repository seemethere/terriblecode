+++
title = 'Merging Local and Remote Apt Repositories'
date = 2018-11-29T11:28:13-08:00
draft = true
tags = ["tags"]
description = "Desc"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

> sudo apt-get install -y docker-ce

If you're using `docker-ce` right now chances are that you proably installed it
with the above command, but the maintenance of the repositories that hold that
artifact can prove troublesome due to the time and environment in which the
repository maintenance tooling was created.

Entire industries have been created over the idea that Debian repositories are
difficult to maintain and a career field (in which I also work) has spawned due
to how specialized this type of work can be.

# Some context

APT repositories historically have been hosted on dedicated nodes that serve
artifacts either through HTTP or through FTP. These nodes would store the
artifacts as well as `Package` indices and other related pieces of information
like GPG keys for verification, etc. Maintaining these nodes can be an arduous
process and copying hundreds of GB's of data can be a pain when you need to go
through things like OS upgrades.

At *Docker* we wanted a bit better of a solution so we looked towards a little
thing called:

![The Cloud](https://imgs.xkcd.com/comics/the_cloud.png)

# Problems with tooling and the Cloud

So with any type of newer technology (*The Cloud*) meshing with older
technology (*APT Repository Management Tooling*) we had issues, but for a long
time those issues could happily be ignored since they didn't really eat up a lot
of time.

And then we started publishing builds on a nightly basis, *queue car screeching
noises*.

So the problem becomes this: when we publish a build of `docker-ce` across the
multiple different operating systems we support across the multiple different
architectures those operating systems support we clock in with a total size of
*new artifacts* at around 915M last time I checked (which is exactly when
I'm writing this blog). Which means that if we're publishing a build every night
about a GB of data is added to our repository every night.

## But why does an extra GB every night even matter?

So let's start with tooling for managing APT repositories.
[`apt-ftparchive`](
https://manpages.debian.org/stretch/apt-utils/apt-ftparchive.1.en.html) is the
tool we use for APT repository management since it's stable and has been used
forever (or that's at least how I understand it). Tooling to replace
`apt-ftparchive` has arisen
([`reprepro`](https://wiki.debian.org/DebianRepository/SetupWithReprepro)
being the best out of all of them) but all-in-all `apt-ftparchive` does its
job and it does it pretty well... except when you don't have everything stored
locally already.

When we moved to a cloud storage solution we quickly found that if the
artifacts that were already included in the `Package` index were not found
locally by `apt-ftparchive` it would remove them from the index altogether.
Which makes sense if you're hosting this on a single node and want an easy
way to remove a package but doesn't make sense if you store everything
remotely and don't want to have to download everything.

So what do you do when you still have releases to do in a short time
and networking is cheap?

> Download everything

![everything](https://media.giphy.com/media/wLXo0vTZSM7GU/giphy.gif)

Now you can probably see where I'm going with this. For the first couple of
months downloading everything was fine, our intial 20GB repository
on a strong network connection only took around 5-10 minutes at most and our
releases were infrequent enough that the growth of that download wasn't really
a major concern... that is until we flicked the switch on `nightly`
builds and our growth exploded.

Pretty soon we found that our 5-10min download was quickly ballooning to
over 40-50min and worst of all `apt-ftparchive` even with a cache was taking
forever to re-index everything. Our release times at this point took a bit of
a nosedive going from something that took ~30 minutes to something that could
take well over 2 hours.

# The search for a better solution

So being at Docker, our first solution immediately gravitated towards overlay
filesystems and having the ability to utilize overlay to have a
pre-downloaded version of our production repositories already on the node. This
approach worked great with our APT repositories but we started seeing issues with
the maintenance of RPM repositories due to a bug in Python's `os.rename` function
as it's utilized in the RPM management tool
[`createrepo`](https://github.com/moby/moby/issues/25409).

After a brief chat with some engineers who had managed RPM repositories I
discovered that RPM has utility that could prove pretty useful for our use-case.

> Name

> [`mergerepo`](https://linux.die.net/man/1/mergerepo) - Merge multiple repositories together

> Synopsis

> mergerepo --repo repo1 --repo repo2

After discovering this utility for RPMs we quickly drew up an MVP and found that
it actually worked! On that side of our repositories our release times were greatly
reduced since we didn't have to download the entire repository in order to update a
remote repository! Unfortunately for us this type of solution didn't seem to exist
for APT repository management... yet.

## Making our own tool

Remember when I said that this type of solution didn't seem to exist yet for APT
repository management? Well I lied, a little bit. `kohsuke`, creator of Jenkins,
had created a solution called
[`apt-ftparchive-merge`](https://github.com/kohsuke/apt-ftparchive-merge)
written in `Java`. Our team, being mostly centered on `Go`, took a look through
the code and decided we could rewrite this utility in `Go` and add things like
tests and a CI/CD pipeline to streamline releases of our utility.

And lo-and-behold our release times went down again! A very noticable improvement
from 2+ hours without verification to ~30 minutes again *with* verification is
nothing to scoff about.

# Introducing `aptmerge`

[`aptmerge`](https://github.com/docker/aptmerge) is the utility we built to
merge remote APT repositories with local APT repositories! It's simple in
that all it tries to do is merge remote indices with local ones and doesn't
try to re-implement already existing tools like `apt-ftparchive`.

Usage is pretty simple, and works with both URLs and local files (which
is how we use it as well)

To merge `Contents` files you can do something like:
```bash
aptmerge contents \
    https://download.docker.com/linux/ubuntu/dists/xenial/test/Contents-amd64 \
    localrepo/Contents-amd64
```

Merging `Packages` files is also straightforward:
```bash
aptmerge packages \
    https://download.docker.com/linux/ubuntu/dists/xenial/test/binary-amd64/Packages \
    localrepo/binary-amd64Packages
```

And then finally when you have `Release` files you can merge those as well!
```bash
aptmerge release \
    https://download.docker.com/linux/ubuntu/dists/xenial/Release \
    localrepo/Release
```

## Tell me where I can get it!

Installation is pretty simple if you're using `go`, you can just use:
```bash
go install github.com/docker/aptmerge
```

There's no real semantic versioning yet since the tool is basic enough that
it hasn't warranted that yet.

Otherwise we're also publishing it as a Docker image so you can actually run
the utility with Docker itself!

```bash
docker run --rm -i -v "$(pwd)":/v -w /v docker/aptmerge --help
```

# Looking towards the future

In the long run we'd like to add some more features to `aptmerge`, with our
list of TODOs looking something like:

* Add the ability to delete packages remotely
* Maybe replicate some functionality of `apt-ftparchive` so we can do have
something like `aptmerge add something.deb remoterepo/`
* Add some versioning so that other users can use the library functions as
part of their own projects

If you have any questions about the project itself feel free to reach out
on the issue tracker at https://github.com/docker/aptmerge or directly to
myself at [@_seemethere](https://twitter.com/@_seemethere).
