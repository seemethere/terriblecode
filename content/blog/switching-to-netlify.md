+++
title = 'Switching to Netlify'
date = 2019-01-03T15:07:24-06:00
draft = false
tags = ["devops"]
description = "Switching my blog over to Netlify"

# For twitter cards, see https://github.com/mtn/cocoa-eh-hugo-theme/wiki/Twitter-cards
meta_img = "/images/logo.png"

# For hacker news and lobsters builtin links, see github.com/mtn/cocoa-eh-hugo-theme/wiki/Social-Links
hacker_news_id = ""
lobsters_id = ""
+++

So this is kind of a follow up to my blog post that I wrote about hosting your
own [static site](
https://terriblecode.com/blog/deploying-static-sites-with-docker-and-ssl/),
which is basically to say that I've stopped hosting/deploying my own site
and I've started to use [`Netlify`](https://netlify.com)!

## Basic Netlify Setup

Netlify was very easy to setup, it followed this basic workflow:

1. Login with Github OAuth
2. Add the site as a site to build
3. Add a `netlify.toml` for deploy previews
4. Add my custom domain (and setup DNS)

## Features of note

### Deploy previews for pull requests / drafts

One of my biggest gripes from deploying my own site was that when I was
collecting feedback from a post that the only real thing I could point
to for my editors was a PR that didn't really signify what the final
product was going to look like. With Netlify however I have the option
to push drafts without worry and have them build only on pull request
builds!

The setup for this is fairly simple in the `netlify.toml`:
```toml
[build]
publish = "public"
command = "hugo"

[context.deploy-preview]
command = "hugo --buildFuture --buildDrafts -b $DEPLOY_URL"
```

### Automatic HTTPS with LetsEncrypt

Once you setup your custom domain and your DNS is verified Netlify will
automatically supply your site with a HTTPS certificate, which is super
easy!

### Autopublishing on push

Before I started using Netlify as my deployment service I was using
`git push live` as my standard to deploy this site. This method was
manual and I _honestly_ sometimes forgot to do it at all when pushing
up a new post.

Now with Netlify I can push to the main repository and be assured that
it'll redeploy my site even if it's a merge on Github!

## Final thoughts
If you're hosting a static site you probably should just use Netlify,
not only is it easy to setup but it provides a lot of great features
that will make your life easier.

![that was easy](https://media.giphy.com/media/zcCGBRQshGdt6/giphy.gif)

Have any questions? ping me over at [@\_seemethere
](https://twitter.com/_seemethere)
