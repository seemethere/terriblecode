+++
title = 'Feature Request: Parallel Stage Generation for Declarative Jenkins Pipelines'
date = 2019-02-26T11:03:06-08:00
draft = false
tags = ["tags"]
description = "Desc"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/image.jpg"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

# A bit of context

Normally a declarative Jenkins pipeline is pretty simple it can look something
like this:

```groovy
pipeline {
    agent {
        label "linux&&x86_64"
    }

    stages {
        stage("Building / Testing") {
            stage("Testing") {
                steps {
                    sh("make test")
                }
            }
            stage("Building") {
                steps {
                    sh("make clean && make")
                }
            }
        }
    }
}
```

But what happens when you need to repeat those stages over and over again,
accounting for a small difference (in terms of code change) of something like
CPU architectures?

For our example we'll need to test that our application tests and builds on
the CPU architectures x86_64, s390x, ppc64le, armv8, armv7, and i386.

# Getting this to work currently

So there's a couple of ways to tackle this currently but both have their
drawbacks and neither can satisfy the three qualities I like in my pipelines:

1. Fully declarative pipelines (no exec'ing out to `script`)
2. DRY (if there's a chance to not repeat let's take it)
3. Maintainability is important

## Just repeat everything (copy / paste me up)

One way to solve this issue is just the brute force way, copy and paste the
stage over and over again in a parallel block. That would probably look pretty
similar to:

```groovy
pipeline {
    agent none

    stages {
        parallel {
            stage("x86_64 Building / Testing") {
                agent { label "x86_64&&linux" }
                stage("Testing") {
                    steps {
                        sh("make test")
                    }
                }
                stage("Building") {
                    steps {
                        sh("make clean && make")
                    }
                }
            }
            stage("s390x Building / Testing") {
                agent { label "s390x&&linux" }
                stage("Testing") {
                    steps {
                        sh("make test")
                    }
                }
                stage("Building") {
                    steps {
                        sh("make clean && make")
                    }
                }
            }
            stage("ppc64le Building / Testing") {
                agent { label "ppc64le&&linux" }
                stage("Testing") {
                    steps {
                        sh("make test")
                    }
                }
                stage("Building") {
                    steps {
                        sh("make clean && make")
                    }
                }
            }
            // ... I think you get the idea
        }
    }
}
```

In terms of fully declarative this approach is awesome, it's distinct and
clear what we're trying to do, but falls short on two of the qualities I
want: maintainability and DRY. This would also make the `Jenkinsfile` a bit
more verbose than what I normally try to go for leading to what could be
confusing for others.

## Just exec out to `script` and generate them like in scripted pipelines

Another approach to this is to just exec out to `script` to run the stages,
which would look somewhat like:

```groovy
def arches = ['x86_64', 's390x', 'ppc64le', 'armv8', 'armv7', 'i386']

archStages = arches.collectEntries {
    "${it} Building / Testing": -> {
        node("${it}&&linux") {
            stage("Testing") {
                checkout scm
                sh("make test")
            }
            stage("Building") {
                sh("make clean && make")
            }
        }
    }
}

pipeline {
    agent none

    stages {
        stage("Building / Testing") {
            script {
                parallel(archStages)
            }
        }
    }
}
```

The only issue with this approach is that it's not fully declarative and
basically defeats the purpose of using a declarative pipeline in the first
place. It's also ugly in the sense that you have define `archStages` so
far before `archStages`. If you had multiple stages before this stage you'd
be hard-pressed to figure out exactly where `archStages` actually comes from.

## The way I'd like it to work

My big wish is that we can have both a maintainable fully declarative
pipeline that is also DRY. But what would something like that actually
look like?

Maybe something like this?

```groovy
pipeline {
    agent none

    stages {
        parallel {
            // The matrix directive would only be available
            // in parallel blocks and is used to generate stages in
            // a declarative fashion
            matrix {
                // Options define a map of options we could potentially have,
                // each map defines a matrix for each individual stage
                opts: [
                    [arch: 'x86_64'],
                    [arch: 's390x'],
                    [arch: 'ppc64le'],
                    [arch: 'armv8'],
                    [arch: 'armv7'],
                    [arch: 'i386'],
                ]
            }

            // To access variables defined in our opts we can use the groovy
            // standard `it`
            stage("${it.arch} Building & Testing")
                agent { label "${it.arch}&&linux" }
                stage("Testing") {
                    steps {
                        sh("make test")
                    }
                }
                stage("Building") {
                    steps {
                        sh("make clean && make")
                    }
                }
            }
        }
    }
}
```
