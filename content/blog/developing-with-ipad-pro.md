+++
title = "Using an iPad Pro as a development machine"
date = 2020-10-05T00:00:00-00:00
draft = true
meta_img = "/images/image.jpg"
tags = ["productivity"]
description = "Moving my development workflow to my iPad Pro!"
hacker_news_id = ""
+++

I believe the 2020s will be a new era of personal computers where the line
between a device like the iPad Pro and the Macbook Pro will be blurred. That's
especially true for a developer like myself, who develops mostly on remote
instances where the client device doesn't really matter so much. This is the
reason I caved this year and bought an iPad Pro (2020 edition)! With this new
device came a different set of challenges, like which freaking app is the best
to use for terminal emulation, and is the magic keyboard case for the iPad
actually usable for a developer who mostly types on mechanical keyboards. So
without further ado, here is my current developer setup for my iPad Pro!

# iPad Pro Specific Things

## Which terminal emulator should I use?

The current terminal emulator that I am using is called [Blink Shell](https://apps.apple.com/us/app/blink-shell-mosh-ssh-client/id1156707581).
It costs about $20  but I have found it be easy to use as well as feature
rich, without getting too confusing. It also just looks great,
I don't know what the developers do to make the font rendering so smooth but
it looks amazing and even supports things like NerdTree fonts! Another plus
is that the developer of Blink Shell has also made a slew of color schemes
and fonts available on Github for anyone else to use / iterate upon, which
is always a plus.

## How's the keyboard case for the iPad Pro?

Coming from someone who is pretty picky about their keyboard situation, the
keyboard that comes with the iPad Pro is probably in the league of the 2019
Macbook Pro magic keyboard. It feels satisfyingly clicky with enough action
in the keys to make you feel as though you've actually pushed a button.

### But what about no ESC key >:(
The lack of an `ESC` key is probably the most disappointing thing about the
keyboard but it's still possible to function with my setup without a dedicated
`ESC` key. Blink shell does have a few options for mapping `CAPS-LOCK` to `ESC`
but I actually prefer the option where you map `CAPS-LOCK` to `CTRL` since it's
more ergonmic for the keybinds I use within `neovim`.

For the `neovim`/`vim` users who are struggling on the iPad Pro magic keyboard,
just get used to typing `CTRL [`, which functions in pretty much the same way
as an `ESC` key.

# But how do you do actual development?

So calling the iPad Pro a development machine is actually a bit of a misnomer.
The iPad Pro is rather a thin client to an actual development machine, which
for now is a Fedora DigitalOcean droplet. SSH'ing to the machine is actually
very simple with Blink Shell, with the app having built in mechanisms for
creating SSH keys as well as having support for things like host aliases.

Another useful feature of Blink Shell is its built in support for `mosh`,
which allows for persistent sessions, even if moving from one network to
another. They even built from `mosh` master since the latest release of
mosh doesn't include things like true color support.

# Final thoughts

The iPad Pro is a device that borders on a pure media consumption device
and a real workhorse. The form factor and keyboard allow it to be a real
replacement for personal development machines for software engineers who
are looking to do some dev work on the side. If you're looking for an extra
device to bring with you, that doesn't weigh as much as another MacBook Pro,
the iPad Pro definitely does the job and more.

If you have any questions feel free to contact me on twitter, [@_seemethere](https://twitter.com/_seemethere)

