# CLAUDE.md

Guidance for coding agents working in this repository.

## Project Summary

This repository contains the source for `terriblecode.com`, a Hugo-based personal site.

The repo is mostly:

- markdown content in `content/`
- static assets in `static/`
- site configuration in `config.toml`
- a vendored Hugo theme as a git submodule in `themes/cocoa-eh`

Production deploys run through Netlify.

## Important Files

- `config.toml`: primary site configuration
- `netlify.toml`: Netlify build settings
- `Makefile`: local dev and build commands
- `.gitmodules`: theme submodule definition
- `themes/cocoa-eh/`: rendering logic and theme assets

## How The Site Works

- Hugo builds the site from `content/`, `static/`, and `config.toml`
- The homepage content comes from `content/home.md`
- Blog posts live in `content/blog/`
- Standalone pages like `about` and `license` live directly under `content/`
- The repo currently has no meaningful root-level layout overrides, so site rendering is primarily determined by the theme submodule

## Local Development

The normal local workflow uses Docker through the `Makefile`.

- `make dev`: runs Hugo in serve/watch mode on port `1313`
- `make`: builds the site into `public/`

If `hugo` is not installed locally, that is expected. Prefer the documented Docker workflow unless the user explicitly wants to switch local tooling.

## Netlify

Netlify is the active deployment target.

- production command: `hugo`
- publish directory: `public`
- deploy previews build drafts and future posts

When documenting or changing deploy behavior, treat Netlify as the source of truth unless the user says otherwise.

## Theme Submodule

`themes/cocoa-eh` is a git submodule, not a normal copied directory.

Agent guidance:

- do not remove the submodule structure
- be careful when editing inside `themes/cocoa-eh`, since those changes belong to the submodule worktree
- if behavior changes can be made in root `layouts/` or config instead of editing the theme directly, prefer the less invasive approach
- if the user wants a theme update, expect to move the pinned submodule commit in the main repo

## Content Conventions

Posts use TOML front matter and may use either lowercase or capitalized keys for tags/categories in existing content. Preserve the surrounding style of the file you are editing instead of normalizing unrelated content.

Draft posts exist in this repo. Do not assume all content under `content/blog/` is published.

## Working Tree Safety

This repo may contain local-only content changes, including untracked drafts. Before editing, check `git status --short` and avoid overwriting or deleting user-authored work that is not part of your task.

## Documentation Guidance

When writing docs for this repo, focus on:

- what content lives where
- how Hugo, the theme, and Netlify fit together
- the Docker-based local workflow
- the fact that most rendering behavior is theme-driven
