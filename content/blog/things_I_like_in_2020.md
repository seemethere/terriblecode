---
title: "fzf and vim, a match made in heaven"
date: 2020-01-24T08:38:36-08:00
tags: ["tools", "vim"]
draft: true
---

Tools are just one of those things that every now and then we need an update.
Just like a carpenter will one day need to update their hammers and saws, we as
software engineers should learn to adapt to the newest tools out there. Here
are some of the tooling updates I've recently introduced into my workflow that
I think would be useful to other developers.

# fzf(.vim)

## Some context

I've been using [`fzf`](https://github.com/junegunn/fzf) for the better part of
3 years and have loved it as a tool for completion on the command line. When
initially trying out the tool I was amazed at how well it worked with my shell
and loved the integrations with common developer workflow like `CTRL-r` and even
autocompletion with tools like `kill`.

From the point that I started using `fzf` I had been using
[`ctrlp`](https://github.com/kien/ctrlp.vim/) as my main way to do fuzzy file
finding in vim, but I had found it suffered when presented with large
directories. Luckily the creator of `fzf` had also created a vim plugin for
`fzf` entitled appropriately as
[`fzf.vim`](https://github.com/junegunn/fzf.vim).

Admittedly, 3 years ago the `fzf.vim` plugin was not ready, in my opinion.
Integration was weird in that it needed a separate terminal window in order
to actually do your fuzzy file finding. This led to new terminal applications
opening up in macOS and cluttering your screen. So at the time I kept with
`ctrlp`.

> Enter 2020

At this point I've started a new job and was in the process of setting up
my new developer environment. With setting up a new environment at a new
company comes some opportunity so I took the chance to try out new things and
decided to dive into `fzf.vim` again.

## Setting it up

### Requirements

In order to use `fzf.vim` as I am using it you need to use

* [`neovim`](https://github.com/neovim/neovim) > `0.4`
* [`ripgrep`](https://github.com/BurntSushi/ripgrep)
* [`findutils`](https://www.gnu.org/software/findutils/) if on `macOS`

### Configuration

Most of the configuration I use is pulled directly from the GitHub repositories
[`README.md`](https://github.com/junegunn/fzf.vim).

~/.config/nvim/init.vim
```vimscript
    " fzf {
        " Using floating windows of Neovim to start fzf
        if has('nvim')
          function! FloatingFZF(width, height, border_highlight)
            function! s:create_float(hl, opts)
              let buf = nvim_create_buf(v:false, v:true)
              let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
              let win = nvim_open_win(buf, v:true, opts)
              call setwinvar(win, '&winhighlight', 'NormalFloat:'.a:hl)
              call setwinvar(win, '&colorcolumn', '')
              return buf
            endfunction

            " Size and position
            let width = float2nr(&columns * a:width)
            let height = float2nr(&lines * a:height)
            let row = float2nr((&lines - height) / 2)
            let col = float2nr((&columns - width) / 2)

            " Border
            let top = '╭' . repeat('─', width - 2) . '╮'
            let mid = '│' . repeat(' ', width - 2) . '│'
            let bot = '╰' . repeat('─', width - 2) . '╯'
            let border = [top] + repeat([mid], height - 2) + [bot]

            " Draw frame
            let s:frame = s:create_float(a:border_highlight, {'row': row, 'col': col, 'width': width, 'height': height})
            call nvim_buf_set_lines(s:frame, 0, -1, v:true, border)

            " Draw viewport
            call s:create_float('Normal', {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2})
            autocmd BufWipeout <buffer> execute 'bwipeout' s:frame
          endfunction

          let g:fzf_layout = { 'window': 'call FloatingFZF(0.9, 0.6, "Comment")' }
        endif

        " Hide statusline
        if has('nvim') && !exists('g:fzf_layout')
          autocmd! FileType fzf
          autocmd  FileType fzf set laststatus=0 noshowmode noruler
            \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
        endif

        map <C-p> :Files<CR>
        let find_command = "find"
        " For some ungodly reason mac's version of find does not include
        " -printf, so we need to switch to gfind here
        if has('macunix')
            let find_command = "gfind"
        endif
        let $FZF_DEFAULT_COMMAND = find_command . " . -type f -not -path '*/\.git/*' -printf '%P\\n'"
        command! -bang -nargs=* Rg
          \ call fzf#vim#grep(
          \   'rg --hidden -g "!.git" --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
          \   fzf#vim#with_preview(), <bang>0)
    " }
```

Some key differences:

* I use a custom `FZF_DEFAULT_COMMAND` in order to auto-include hidden files,
excluding those in `.git`
* I use a custom `rg` command that does similar things to my
`FZF_DEFAULT_COMMAND`
* I add the `CTRL-p` default keybind to bring up the fuzzy file finder

## Some demos

### fzf.vim searching through files

With my config searching through files in your git repo is as easy as
just pressing `CTRL-p`.

With neovim this key bind will bring up a floating window that allows
you to enter the name of the file that your are searching for.

In this example we'll be searching for a python script that we think is
named `should_run.py`

![showing file search](https://i.imgur.com/jh8AefN.mp4)
