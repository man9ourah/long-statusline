Fast and Git-featured Vim StatusLine
====================================

To boost the performance:
* Much of the status line is built statically, i.e. modes labels and colors, and
all of the highlight groups.
* Git information is retrieved asynchronously.
* Use cache for Git information, and only update after a buffer write event.

Due to the above, redrawing the status line require **only** reading data from
dictionaries that are built either statically, or asynchronously. 

Startup time is also important, and so there is no computation during startup,
only loading functions, and defining the highlight groups. 

Git information are retrieved asynchronously once for every buffer when it is 
opened, and then again with every buffer write. 

As tested on my machine, and following the procedure at
[vim-crystalline performance comparison](https://github.com/rbong/vim-crystalline/wiki/Performance-Comparison),
this status line have total redraw time of `0:00.15` and a total startup time of
`0:01.58` for 100 runs. Surely,
this is not a comparison to the results in the linked page as my machine could
be different.

Also, checkout [profiling results](profiling_results/logs) to see detailed
execution times of 5 runs. As can be seen, the function `SetStatusLine()`, which
is the function that is called to redraw the status line, have
a less than `1ms` average execution time. 

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
* Much faster than other status lines plugins, some of which have less features.

## Demo of the Git features

Here: [asciinema](https://asciinema.org/a/08MKjRT785EKIaRIxOlgpZzG9)

Notice how I can immediately move my cursor right after I write all buffers at
once, and the Git information are updated instantly without blocking the UI.

*Please ignore the messed up unicode symbols in the cast. You can see the actual
symbols as they show in my screen in the image below.*

## Demo of my setup

![screenshot](screenshot.png)

## Installation

This is meant as a personal project, as the whole point is to build something
that is solely focused on delivering a super fast status line plugin without
worrying about compatibility issues and the likes. 

If you want to use this plugin, I recommend you to use it as a template for your status
line plugin. The code is only about `500 lines`, and it has comments all over it,
but please feel free to ask about anything in the code. 

You may also take out the Git functionality out of this project and integrate it
with [lightline.vim](https://github.com/itchyny/lightline.vim/),
[vim-airline](https://github.com/vim-airline/vim-airline), or
[vim-crystalline](https://github.com/rbong/vim-crystalline). 

## Dependencies
**Required dependencies** 
* [Asyncrun](https://github.com/skywind3000/asyncrun.vim): To get Git
  information asynchronously without a slowdown.

**To match the setup that I have**: 
* [YCM](https://github.com/ycm-core/YouCompleteMe): For errors and warnings.
* [TagList](https://github.com/yegappan/taglist): Status line spans Taglist's
  window too.


You can view my [vimrc](vimrc/vimrc.vim) to see my full Vim setup.

### More
The colorscheme is in `colors/`, you just need to symlink it in vim's
`colors/` directory.
