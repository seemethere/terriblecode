+++
title = 'Locking Package Versions with Apt and Yum'
date = 2019-10-29T14:36:51-07:00
draft = false
tags = ["devops", "packaging"]
description = "Have you ever wondered how to lock specific packages to specific versions? Well wonder no more."

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

Limiting package versions (especially for updates) is a common pain point
most enterprise customers will experience at one point or another.

In this blog post I will cover how to do version locking for the 2 most
popular enterprise package managers.

# yum

### Distributions covered/tested:

* CentOS 7
* RHEL 7.X

### Instructions

There is an [official document](https://access.redhat.com/solutions/98873) on how to do this
from RHEL but I'll boil it down to the most important parts. This utilizes an official RHEL
package called `yum-plugin-versionlock`.

```shell
# install plugin
yum install yum-plugin-versionlock

# Specify a version to pin to
VERSION=2

# add versionlock for your package
yum versionlock mypackage-${VERSION}*

# install your package with the new versionlock
yum install -y mypackage

# to update your package clear the versionlock
yum versionlock clear *mypackage*
# and the reinstantiate it
yum versionlock mypackage-${VERSION}*
yum update -y mypackage
```

# apt

### Distributions covered/tested:

* Ubuntu 18.04

### Instructions

apt has the concept of package pinning based off of regexes which is extremely useful.

Limiting package updates for `apt` is as simple as adding a new file:

`/etc/apt/preferences.d/mypackage`
```
Package: mypackage
Pin: version /2/
Pin-Priority: 999
```

The nice thing about this is that this file can actually last through multiple
`apt upgrade`'s.
