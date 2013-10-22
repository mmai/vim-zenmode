"==============================================================================
"File:        zenmode.vim
"Description: Vaguely emulates a writeroom-like environment in Vim by
"             splitting the current window in such a way as to center a column
"             of user-specified width, wrap the text, and break lines.
"             This is a stripped down version of vimroom by Mike West
"             (http://projects.mikewest.org/vimroom/), with some
"             enhancements.
"Maintainer:  Henri Bourcereau <henri@rhumbs.fr>
"Version:     0.2
"Last Change: 2013-02-02
"License:     BSD 
"==============================================================================

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Configuration
"

" The typical start to any vim plugin: If the plugin has already been loaded,
" exit as quickly as possible.
if exists( "g:loaded_zenmode_plugin" )
    finish
endif
let g:loaded_zenmode_plugin = 1

" The desired font. Defaults to the current font (suggested : Cousine 12)
if !exists( "g:zenmode_font" )
  let g:zenmode_font = &guifont
endif

" The desired background. Defaults to dark
if !exists( "g:zenmode_background" )
  let g:zenmode_background ="dark"
endif

" The desired colorscheme. Defaults to desert (suggested : solarized)
if !exists( "g:zenmode_colorscheme" )
  let g:zenmode_colorscheme ="desert"
endif

" The desired column width.  Defaults to 80:
if !exists( "g:zenmode_width" )
    let g:zenmode_width = 80
endif

" The minimum sidebar size.  Defaults to 5:
if !exists( "g:zenmode_min_sidebar_width" )
    let g:zenmode_min_sidebar_width = 5
endif

" The sidebar height.  Defaults to 3:
if !exists( "g:zenmode_sidebar_height" )
    let g:zenmode_sidebar_height = 3
endif

" The "scrolloff" value: how many lines should be kept visible above and below
" the cursor at all times?  Defaults to 999 (which centers your cursor in the 
" active window).
if !exists( "g:zenmode_scrolloff" )
    let g:zenmode_scrolloff = 999
endif

" Should Zenmode map navigational keys (`<Up>`, `<Down>`, `j`, `k`) to navigate
" "display" lines instead of "logical" lines (which makes it much simpler to deal
" with wrapped lines). Defaults to `1` (on). Set to `0` if you'd prefer not to
" run the mappings.
if !exists( "g:zenmode_navigation_keys" )
    let g:zenmode_navigation_keys = 1
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Code
"

" Given the desired column width, and minimum sidebar width, determine
" the minimum window width necessary for splitting to make sense
let s:minwidth = g:zenmode_width + ( g:zenmode_min_sidebar_width * 2 )

" We're currently in nonzenmodeized state
let s:active   = 0

function! s:is_the_screen_wide_enough()
  return winwidth( winnr() ) >= s:minwidth
endfunction

function! s:sidebar_size()
  return ( winwidth( winnr() ) - g:zenmode_width - 2 ) / 2
endfunction

function! <SID>ZenmodeToggle()
  " Maximize gvim window.
  if has("gui_running")
    set lines=55 columns=155
  endif

  " Set spell checking
  if exists( "g:zenmode_spell" )
    exec "set spelllang=".g:zenmode_spell." spell"
  endif

  "Set the new font BEFORE testing window width
  exec "set gfn=".escape(g:zenmode_font,' ')

  exec "set background=".escape(g:zenmode_background,' ')
  exec "colorscheme ".escape(g:zenmode_colorscheme,' ')

  if s:is_the_screen_wide_enough()
    let s:active = 1

    " Turn off Powerline
    if exists('Powerline')
        autocmd! Powerline
    endif
    " Turn off Airline
    if exists(':AirlineToggle')
        :AirlineToggle
    endif

    " Disable line numbering, if numbers.vim is enabled
    if exists(':NumbersDisable')
        :NumbersDisable
    endif


    " Turn off menus
    set guioptions=

    " Turn off status bar
    set laststatus=0
    set statusline=

    let s:sidebar = s:sidebar_size()
    if g:zenmode_min_sidebar_width
      " Create the left sidebar
      exec( "silent leftabove " . s:sidebar . "vsplit new" )
      setlocal noma
      setlocal nocursorline
      setlocal nonumber
      silent! setlocal norelativenumber
      wincmd l
      " Create the right sidebar
      exec( "silent rightbelow " . s:sidebar . "vsplit new" )
      setlocal noma
      setlocal nocursorline
      setlocal nonumber
      silent! setlocal norelativenumber
      wincmd h
    endif
    if g:zenmode_sidebar_height
      " Create the top sidebar
      exec( "silent leftabove " . g:zenmode_sidebar_height . "split new" )
      setlocal noma
      setlocal nocursorline
      setlocal nonumber
      silent! setlocal norelativenumber
      wincmd j
      " Create the bottom sidebar
      exec( "silent rightbelow " . g:zenmode_sidebar_height . "split new" )
      setlocal noma
      setlocal nocursorline
      setlocal nonumber
      silent! setlocal norelativenumber
      wincmd k
    endif
    " Setup wrapping, line breaking, and push the cursor down
    set wrap
    set linebreak

    set nonumber
    silent! set norelativenumber

    exec( "set textwidth=".g:zenmode_width )
    exec( "set scrolloff=".g:zenmode_scrolloff )

    " Setup navigation over "display lines", not "logical lines" if
    " mappings for the navigation keys don't already exist.
    if g:zenmode_navigation_keys
      try
        noremap     <unique> <silent> <Up> g<Up>
        noremap     <unique> <silent> <Down> g<Down>
        noremap     <unique> <silent> k gk
        noremap     <unique> <silent> j gj
        inoremap    <unique> <silent> <Up> <C-o>g<Up>
        inoremap    <unique> <silent> <Down> <C-o>g<Down>
      catch /E227:/
        echo "Navigational key mappings already exist."
      endtry
    endif

    " Hide distracting visual elements
    if has('gui_running')
      let l:highlightfgbgcolor = "guifg=bg guibg=bg"
    else
      let l:highlightfgbgcolor = "ctermfg=bg ctermbg=bg"
    endif
    exec( "hi VertSplit " . l:highlightfgbgcolor )
    exec( "hi NonText " . l:highlightfgbgcolor )
    exec( "hi StatusLine " . l:highlightfgbgcolor )
    exec( "hi StatusLineNC " . l:highlightfgbgcolor )
    set t_mr=""
    set fillchars+=vert:\ 
  else
    echo "Not enough space..."
  endif
endfunction

" Create a mapping for the `ZenmodeToggle` function
noremap <silent> <Plug>ZenmodeToggle    :call <SID>ZenmodeToggle()<CR>

" Create a `ZenmodeToggle` command:
command -nargs=0 ZenmodeToggle call <SID>ZenmodeToggle()

" If no mapping exists, map it to `<Leader>V`.
if !hasmapto( '<Plug>ZenmodeToggle' )
    nmap <silent> <Leader>Z <Plug>ZenmodeToggle
endif
