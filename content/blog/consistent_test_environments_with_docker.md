+++
date = "2017-03-29T14:38:39-05:00"
title = "Dockerizing Python Test Environments"
author = "Eli Uriegas"
draft = true

+++

# Context

![Failing pull requests](/img/failing_pull_requests.png)

It's every maintainer's nightmare to see these types of failures on PR's.
Nothing in the code base had changed and tests were passing locally, but almost
every build we pushed through was failing. I spent so long trying to figure
out why they were failing on Travis CI but not on my local machine, but could not
find any reason why it was actually happening. Then, I did what any developer would
do in a similar situation: I spun up a virtual machine close to what Travis CI
would be like and tried to recreate the steps through there.

# Virtual Machine Troubles

I've been using virtual machines for a while (yay for having a Windows machine in
college) so I would say I am pretty familiar with them. My favorite virtual machine
management tool is VMware Workstation and it's fairly simple to create a new machine, but
the time it takes to do this can be costly. The time taken is negligible if the machine
is supposed to be persistent (like an ubuntu box for school) but for use cases like needing
consistent testing environments it may prove to be a bit longstanding. So being
the studious developer I am I decided now is a great time to learn how to do this in a
more automated fashion. In comes **Docker**!

# How can Docker help?

With Docker we can be assured everyone uses the same base image and that the only
things done in the container are the things we prescribe (as specified in a `Dockerfile`).
We can also use a `Makefile` to make it easier for users to run a single command instead
of maybe two or three commands. Execution (when including the creation of the Docker image)
may take longer but having the consistency of testing environments is invaluable when
trying to run unittests.

# How do we implement it?

Implementation of this type of unittesting was fairly trivial requiring only about eight
lines of real *code*.

## The Dockerfile
```
FROM python:3.6

ADD . /app
WORKDIR /app

RUN pip install tox
```

This file will tell Docker to build an image from the base image `python:3.6` which includes
python3.6 obviously and all the tools necessary to compile CPython extensions as well. It will
also add our current application code as a volume on the container and then change our working
directory to that application folder. Finally it will install `tox` on the container and prep
it for running actual tests.

## The Makefile
```make
test:
    # Remove all cached pyc files, they don't play nice with the containers
    find . -name "*.pyc" -delete
    # Build the docker image
    docker build -t sanic/test-image .
    # Run `tox` on the image
    docker run -t sanic/test-image tox
```

The makefile combines 3 commands to make running the unittests possible. The first removes
all `pyc` files contained in the application folder so that they don't interfere when we try
to run tests inside of the container. Next is the command that actually builds the test
image using the `Dockerfile`. And last is the command that runs `tox` on the container
which will show us how results of actually running the tests.

# So what are the drawbacks?
So this approach is good for our use case but recreating images creates a lot of cruft
after so many runs in the form of untagged images. Also a lot of exited containers are
created as well which becomes really unsightly after running `docker ps -a` and
seeing a bunch of exited containers.

## How do we clean it up?
A lot of blog posts have been written about how to clean up exited containers as well as
untagged images with my favorite being one by
[Jim Hoskins](http://jimhoskins.com/2013/07/27/remove-untagged-docker-images.html). Just in
case you don't want to read it though here are the commands.

### For cleaning containers:
```shell
docker rm $(docker ps -a -q)
```

### For cleaning images:
```shell
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
```

# Conclusion
Dockerizing environments for use with python testing is useful for those who dev on multiple different
machines. It allows us to have a consistent testing environment that is nearly guaranteed to be the
same almost every single time. Most importantly, it's easy. The ramp up time to get this type of
workflow going is minimal so why wouldn't you be doing it?
