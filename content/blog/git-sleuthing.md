+++
title = 'Dissecting a code base, the search for gifted_c**ks'
date = 2019-02-23T16:39:43-08:00
draft = true
tags = ["linux", "commandline"]
description = "Searching through a mostly unfamiliar codebase for naughty words"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Oh my docker! You are really making me blush (and giggle like a schoolboy) <a href="https://t.co/NOACbM89di">pic.twitter.com/NOACbM89di</a></p>&mdash; Julie Lerman (@julielerman) <a href="https://twitter.com/julielerman/status/1099043183776985088?ref_src=twsrc%5Etfw">February 22, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

# Initial exploration

Recently I was pinged on a particular issue responding to the inclusion of
potentially offensive language inside of a repository so I did a bit of initial
investigation and found that the particular offensive language was not included
in the latest checkout of said repository.

Getting to that point is particularly easy, just a simple checkout of the
upstream like so:
```
# Clone down our source
git clone git@github.com:moby/moby.git docker
```

# Digging a bit deeper for context

Now I wasn't too sure where to find the code related to the inclusion of the
offensive language but I knew that I could start looking in certain places.
So my first place to look at is any place where `container.go` is since that's
probably where containers are defined in terms of how they start and exist.

With a quick search we can pull up a list of files like so:
```
❯ find . -name "*container.go"
./integration/internal/container/container.go
./internal/test/daemon/container.go
./container/container.go
./daemon/cluster/executor/container/container.go
./daemon/cluster/convert/container.go
./daemon/container.go
./api/types/swarm/container.go
./api/server/router/container/container.go
./vendor/github.com/Microsoft/hcsshim/container.go
./vendor/github.com/containerd/containerd/container.go
./vendor/github.com/containerd/go-runc/container.go
```

Off the bat we can get rid of anything in the `./vendor` folder since that
probably doesn't have anything to do with my search, which leaves us with:

```
./integration/internal/container/container.go
./internal/test/daemon/container.go
./container/container.go
./daemon/cluster/executor/container/container.go
./daemon/cluster/convert/container.go
./daemon/container.go
./api/types/swarm/container.go
./api/server/router/container/container.go
```

Once again from this we can narrow it down even more, anything dealing with
distributed containers (i.e. `swarm`, `cluster`) can be eliminated leaving
us again with:

```
./integration/internal/container/container.go
./internal/test/daemon/container.go
./container/container.go
./daemon/container.go
./api/server/router/container/container.go
```

I'm pretty aware that the `moby/moby` repository contains an integration
test suite which doesn't really have anything to do with starting containers
so let's just go ahead and remove those as well. This leaves us with 3 files.

```
./container/container.go
./daemon/container.go
./api/server/router/container/container.go
```

## Searching the code itself

Now I'm going to search through these files for things that I might want,
some tips here is that functions usually begin with a full space so you
can add that to the beginning of your search patttern if you're searching
for a function

```
❯ grep -inE ' (create|new)' daemon/container.go \
    container/container.go \
    api/server/router/container/container.go
daemon/container.go:128:func (daemon *Daemon) newContainer(name string, operatingSystem string, config *containertypes.Config, hostConfig *containertypes.HostConfig, imgID image.ID, managed bool) (*container.Container, error) {
daemon/container.go:186:// newBaseContainer creates a new container with its initial
daemon/container.go:188:func (daemon *Daemon) newBaseContainer(id string) *container.Container {
daemon/container.go:295:		return nil, errors.Errorf("can't create 'AutoRemove' container with restart policy")
container/container.go:109:// NewBaseContainer creates a new container with its
container/container.go:111:func NewBaseContainer(id, root string) *Container {
container/container.go:114:		State:         NewState(),
container/container.go:144:	// host OS if not, to ensure containers created before multiple-OS
container/container.go:356:// StartLogger starts a new logger driver for the container.
container/container.go:433:// AddMountPointWithVolume adds a new mount point configured with a volume to the container.
container/container.go:503:// New containers don't ever have those fields nil,
container/container.go:504:// but pre created containers can still have those nil values.
container/container.go:554:// ResetRestartManager initializes new restartmanager based on container config
container/container.go:678:// CreateDaemonEnvironment creates a new environment variable slice for this container.
container/container.go:679:func (container *Container) CreateDaemonEnvironment(tty bool, linkedEnv []string) []string {
api/server/router/container/container.go:15:// NewRouter initializes a new container router
api/server/router/container/container.go:16:func NewRouter(b Backend, decoder httputils.ContainerDecoder) router.Router {
```

Out of this search result I can see a couple of functions that actually
look like what I'm looking for:
```
daemon/container.go:128:func (daemon *Daemon) newContainer(name string, operatingSystem string, config *containertypes.Config, hostConfig *containertypes.HostConfig, imgID image.ID, managed bool) (*container.Container, error) {
container/container.go:111:func NewBaseContainer(id, root string) *Container {
```

## Diving into the code

So now that we've narrowed our search to 2 lines in a specific file we can start
snooping around the code to find our offensive language suspect.

From snippets we can find that code for `newContainer` contains a line that
that might give us exactly what we need:

```go
func (daemon *Daemon) newContainer(name string, operatingSystem string, config *containertypes.Config, hostConfig *containertypes.HostConfig, imgID image.ID, managed bool) (*container.Container, error) {
    var (
        id             string
        err            error
        noExplicitName = name == ""
    )
    id, name, err = daemon.generateIDAndName(name)
    if err != nil {
        return nil, err
    }
```

Here I'm seeing that this function calls another function called
`generateIDAndName` which generates the `name` that the container itself
eventually inherits, *supposedly*. This is actually where I stopped reading
the function and dived directly into `generateIDAndName` which looks something
like:

```go
func (daemon *Daemon) generateIDAndName(name string) (string, string, error) {
    var (
        err error
        id  = stringid.GenerateNonCryptoID()
    )

    if name == "" {
        if name, err = daemon.generateNewName(id); err != nil {
            return "", "", err
        }
        return id, name, nil
    }

    if name, err = daemon.reserveName(id, name); err != nil {
        return "", "", err
    }

    return id, name, nil
}
```

Which leads me to `daemon.generateNewName` which looks like:

```go
func (daemon *Daemon) generateNewName(id string) (string, error) {
    var name string
    for i := 0; i < 6; i++ {
        name = namesgenerator.GetRandomName(i)
        if name[0] != '/' {
            name = "/" + name
        }

        if err := daemon.containersReplica.ReserveName(name, id); err != nil {
            if err == container.ErrNameReserved {
                continue
            }
            return "", err
        }
        return name, nil
    }

    name = "/" + stringid.TruncateID(id)
    if err := daemon.containersReplica.ReserveName(name, id); err != nil {
        return "", err
    }
    return name, nil
}
```

Which once again leads me to `namesgenerator.GetRandomName`, which again looks
like:

```go
// GetRandomName generates a random name from the list of adjectives and surnames in this package
// formatted as "adjective_surname". For example 'focused_turing'. If retry is non-zero, a random
// integer between 0 and 10 will be added to the end of the name, e.g `focused_turing3`
func GetRandomName(retry int) string {
begin:
    name := fmt.Sprintf("%s_%s", left[rand.Intn(len(left))], right[rand.Intn(len(right))])
    if name == "boring_wozniak" /* Steve Wozniak is not boring */ {
        goto begin
    }

    if retry > 0 {
        name = fmt.Sprintf("%s%d", name, rand.Intn(10))
    }
    return name
}
```

At this point after browsing through the file that I am led to
(`pkg/namesgenerator/names-generator.go`) I believe that I am in the right file.

So from this point I do a once again do quick grep for our offensive word:

```
❯ grep -inE "cocks" pkg/namesgenerator/names-generator.go
```

Which of course leads to nothing again just like it did before (no suprise here).

Now that we have our file we can now start doing git magic.

# Git magic to find out when it was removed

From this point I've narrowed down my search to a singular file and now I want
to know when this word was removed and by whom it was removed by.

I know that the user who reported this is using Docker version `18.09.0` so I
can start from that tag.

Since Docker hosts tags in a different repository I need to add the repository
that hosts the tags to my remotes and fetch all tags:

```
❯ git remote add docker-fork git@github.com:docker/engine
❯ git fetch --all
```

After fetching all tags I can do a git log on the file in order to pull
all relevant commits that happened from the previous release to the current
commit with:

```
❯ git log --grep "cocks" v18.09.0...HEAD -- pkg/namesgenerator/names-generator.go
commit e50f791d42d1167a5ef757b1aa179e84f0f81bba
Author: Debayan De <debayande@users.noreply.github.com>
Date:   Sun Dec 23 10:22:28 2018 +0000

    Makes a few modifications to the name generator.

    * Replaces `cocks` with `cerf` as the former might be perceived as
    offensive by some people (as pointed out by @jeking3
    [here](https://github.com/moby/moby/pull/37157#commitcomment-31758059))
    * Removes a duplicate entry for `burnell`
    * Re-arranges the entry for `sutherland` to ensure that the names are in
    sorted order
    * Adds entries for `shamir` and `wilbur`

    Signed-off-by: Debayan De <debayande@users.noreply.github.com>
```

And *Boom*! We have our removal commit, with a nice commit message to boot
(shoutout to Debayan!). As told by the date Docker hasn't actually released a
version containing this patch yet but patch is there in upstream right now!

After writing this blog post I now realize I could've just done the `git log`
call from the very beginning but there's no fun in that and now we know a
little bit more about how Docker generates the names for containers!

Have any questions? ping me over at [@\_seemethere
](https://twitter.com/_seemethere)
