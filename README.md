Long StatusLine
===============

I wanted to build a vim status line that have all the features I want, but also
fast. Status line plugins like
[vim-airline](https://github.com/vim-airline/vim-airline) and
[lightline.vim](https://github.com/itchyny/lightline.vim) have to trade
**compact**ibility with compatibility, which is understandable given the number of
their users. However, this definitely have an impact on the performance of the
plugin, and thus vim's overall performance. 

So, I decided to build `LongStl` focusing on performance and the features I have
in mind. 

To boost the performance:
* Much of the status line is built statically, i.e. modes labels and colors, and
all of the highlight groups.
* Git information is retrieved asynchronously.
* Use cache for Git information, and only update after a buffer write event.

Due to the above, redrawing the status line require **only** reading data from
dictionaries that are built either statically, or asynchronously. 

Startup time is also important, and so there is no computation during startup,
only loading functions, and defining the highlight groups. 

Git information are retrieved once for every buffer when it is opened, and then
again with every buffer write. 

As tested on my machine, and following the procedure at
[vim-crystalline performance comparison](https://github.com/rbong/vim-crystalline/wiki/Performance-Comparison),
`LongStl` have total redraw time of `0:00.15` and a total startup time of
`0:01.58` for 100 runs. Surely,
this is not a comparison to the results in the linked page as my machine could
be different.

## Features 
* Git: branch or short commit id.
* Git: status i.e. dirty or clean repo.
* Git: if file is tracked or not.
* Git: number of inserted / deleted lines. 
* File path relative to git root if in git.
* Number of compilation errors in the code.
* Number of compilation warnings in the code.
* Date and time.
* Greyed out for inactive windows.
* Mode label coloring based on mode.
* Much faster than other status lines plugins, some of which have less features than
  `LongStl`.

## Demo

![screenshot](screenshot.png)

## Dependencies

* [YCM](https://github.com/ycm-core/YouCompleteMe): For errors and warnings.
* [TagList](https://github.com/yegappan/taglist): Status line spans Taglist's
  window too.
* [Asyncrun](https://github.com/skywind3000/asyncrun.vim): To get Git
  information asynchronously without a slowdown.

This is meant as a personal project; as the whole point is to avoid runtime
configuration. But you may use it at your own risk. You
can view my [vimrc](vimrc/vimrc.vim) to see my full Vim setup and replicate in
your system, hopefully not many changes are needed.

### More
The colorscheme is in `colors/`, you just need to symlink it in vim's
`colors/` directory.
