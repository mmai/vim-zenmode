vim-zenmode
===========

This plugin transforms vim into a distraction free editor similar to writeroom or iaWriter.

Zen mode is based on [Vimroom](http://projects.mikewest.org/vimroom/) by
Mike West. It has only been tested on gvim + Xubuntu

Installation
------------

1. Install [pathogen.vim](https://github.com/tpope/vim-pathogen) if you haven't
already done so, then simply execute:

```shell
      cd ~/.vim/bundle
      git clone git://github.com/mmai/vim-zenmode.git
```
2. Install a good looking monospaced font :

```vim
      cd ~/.font
      curl http://www.fontsquirrel.com/fonts/download/cousine > cousine.zip
      unzip cousine.zip
      fc-cache -vf ~/.font
```

3. Configure zenmode font and colorscheme in your .vimrc :

```vim
      "Zenmode
      let g:zenmode_background = "dark"
      let g:zenmode_colorscheme = "solarized"
      let g:zenmode_font ="Cousine 12"
```

Usage
-----

* Open gvim. Expand your window if necessary
* Switch to Zen Mode with _<LEADER> + Z_
* Go Full Screen (ALT + F11 on Xubuntu)
* Write great things
* Quit with :qa (there are many windows to close)

Tips
----

* If you plan to use Zenmode when writing markdown documents, installing
[vim-markdown](https://github.com/plasticboy/vim-markdown) is a good way to enhance your experience.
* Get your document words count with :
```
g <CTRL>+g
```
