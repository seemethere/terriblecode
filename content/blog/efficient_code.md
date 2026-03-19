+++
Tags = ["Release Engineering"]
Description = ""
date = "2022-05-21T00:00:00-00:00"
title = "Effective Release Engineering Part 1: Local Scripting"
Categories = ["Release Engineering"]
draft = true 
author = "Eli Uriegas"
authorlink = "http://github.com/seemethere"

+++

# What is Release Engineering?

Release engineering seems to be a pretty niche topic and, based on my experience,
something that is an opportunity to specialize if you're looking for a career 
specialization. There's a lot of definitions of release engineering, but for the 
purposes of this series I'll define release engineering in the following context:

* Writing automation for the deployment of software
  * Typically includes figuring out how to package the software as well
* Writing automation for the verification of software's quality
  * Typically includes writing CI pipelines and providing environments for tests to run in
* Building the infrastructure for that automation to run in (if you're lucky, or unlucky depending on your perspective)

In my experience, most of the release engineering work that I've done has fallen
into these buckets. In this series I'm hoping to give an overview of building
release pipelines from the ground up, going from the simplest form of automation
to more complex examples.

# When should I write a script?

A common comment you might hear when thinking about automating a particular
process is that it might take too much time to write the automation, however
automation should be viewed from the lens of how much time it'll take to write,
it should be a function of finding how much time it'll save. For an engineer,
it might make sense to run a bunch of repeated commands locally because hitting
the up arrow in your terminal is _easy_ and takes _less_ time than writing a
script. This type of thinking is mostly correct, however in order to build
maintainable systems, we need to write automation because we're usually not
the only ones who'll have to run / understand these commands in the future.

> For a rule of thumb, if you have to run anything more than 3 times, just write a script and commit it somewhere.
> It'll be easier for you in the long run and if someone else has to do the same thing at least they have a place to start

# Writing effective / testable shell scripts

For the purposes of my sanity, and to illustrate the most common form of 
automation, I'm going to focus on giving tips on how to write better
`bash` scripts for automation / release engineering.

## Having sane defaults for arguments and why environment variables are the best for shell scripts

For my shell scripts I typically like to not have an argument parser and
instead rely on environment variables that have sane defaults for testing
purposes. 

Why environment variables though? Environment variables are very easy to
pass through automation, they're easily auditable (meaning you can see their values using `env`),
and there's a very easy way to define a default if an environment variable
isn't set (at least in most languages).

For `bash` the way to do this is:
```bash
MY_COOL_ENV_VARIABLE=${MY_COOL_ENV_VARIABLE:-the_default_value}
```

<details>
<summary> An example for my pythonistas </summary>

```python
import os
my_cool_env_variable = os.env.get("MY_COOL_ENV_VARIABLE", "the_default_value)
```

</details>

### A note about using `export` in your shell scripts

Just don't do it, don't assume anyone running these scripts wants these environment variables to exist
in their local shell. Even if a script is _only_ supposed to run in CI, someone will eventually
try to run it locally and cleaning your local env after a script sets 100 environment variables for
you is _very annoying_. Using global variables is a bad practice in most languages so we shouldn't
make an exception for `bash`

## Debug logging is great, we should do it more (when appropriate)

`bash` actually has a built in way to do debug logging through the `set -x` flag. For most
automation scripting though there might some parts of the script that don't "do work", so
we should probably only print debug logs for the most important of commands. As well, we should
focus on adding unique print statments to parts of the code that do work or are prone to
failure so that we can the find place easily if things do go wrong.

An easy way to do this in `bash` is to utilize sub-shells:

```bash
CURRENT_BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}
REMOTE=${REMOTE:-origin}

# Adding a unique print statment to find where we are in the script
echo "+ git-yolo-push: AMENDING CURRENT COMMIT AND FORCE PUSHING"
# SUBSHELL where only the git commands should show like
# + git commit -as --amend --no-edit
# + git push -fu "origin" "my_cool_branch"
(
    set -x
    git commit -as --amend --no-edit
    git push -fu "${REMOTE}" "${CURRENT_BRANCH}"
)
# any commands after the SUBSHELL won't display
```

> In general providing debug logging should make it so that when things go wrong 
> it's easier to find the place to start looking. When in doubt add a unique print 
> statement.

## Dry runs are the best runs



## Outline:
* Local scripting
  * Writing effective/testable shell scripts
  * Debug logs are great, we should do more of them
  * The wonders of dry runs and the value of seeing what's going to get run