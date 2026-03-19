# terriblecode

Source for [terriblecode.com](https://terriblecode.com/).

This repository is a Hugo-based personal site. Content lives in this repo, the site theme is vendored as a git submodule, and production is deployed with Netlify.

## Stack

- [Hugo](https://gohugo.io/) for static site generation
- Netlify for production deploys and deploy previews
- `cocoa-eh` as a git submodule under `themes/cocoa-eh`
- Docker-based local development via `make`

## Repository Layout

- [`config.toml`](/Users/eliasuriegas/projects/terriblecode/config.toml): site configuration, social links, analytics, and theme settings
- [`content/`](/Users/eliasuriegas/projects/terriblecode/content): site content
- [`content/blog/`](/Users/eliasuriegas/projects/terriblecode/content/blog): blog posts
- [`static/`](/Users/eliasuriegas/projects/terriblecode/static): images and other static assets
- [`themes/cocoa-eh/`](/Users/eliasuriegas/projects/terriblecode/themes/cocoa-eh): Hugo theme submodule
- [`Makefile`](/Users/eliasuriegas/projects/terriblecode/Makefile): local development commands
- [`netlify.toml`](/Users/eliasuriegas/projects/terriblecode/netlify.toml): Netlify build configuration

## Content Model

The site is mostly driven by markdown content plus theme conventions:

- [`content/home.md`](/Users/eliasuriegas/projects/terriblecode/content/home.md) provides the homepage intro
- [`content/about.md`](/Users/eliasuriegas/projects/terriblecode/content/about.md) and [`content/license.md`](/Users/eliasuriegas/projects/terriblecode/content/license.md) are standalone pages
- blog posts live in [`content/blog/`](/Users/eliasuriegas/projects/terriblecode/content/blog) with TOML front matter

Common front matter fields used in this repo include:

- `title`
- `date`
- `tags` or `Tags`
- `categories` or `Categories`
- `draft`
- `author`

The active theme renders:

- homepage intro content
- a latest-posts list
- optional best-posts sections
- blog post metadata like reading time and tags

## Local Development

This repo’s `Makefile` expects Docker and uses the `seemethere/hugo-docker` image.

Start a local server:

```sh
make dev
```

Generate the site:

```sh
make
```

The local dev server is configured to bind Hugo to port `1313`.

## Netlify Deployment

Production is deployed by Netlify using [`netlify.toml`](/Users/eliasuriegas/projects/terriblecode/netlify.toml):

- publish directory: `public`
- production build command: `hugo`
- deploy preview command: `hugo --buildFuture --buildDrafts -b $DEPLOY_URL`

That means deploy previews include draft and future-dated content, while production uses the default Hugo build behavior.

## Theme Submodule

The site theme is tracked as a git submodule:

```sh
git submodule update --init --recursive
```

If you clone the repo without submodules, the site will be missing its theme.

Theme updates are managed by advancing the submodule pointer and committing the updated reference in the main repo.

## Notes

- There are currently no root-level layout overrides, so most rendering behavior comes from the `cocoa-eh` theme.
- Site metadata like analytics, author information, and social links are configured in [`config.toml`](/Users/eliasuriegas/projects/terriblecode/config.toml).
