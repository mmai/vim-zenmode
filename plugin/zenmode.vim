"==============================================================================
"File:        zenmode.vim
"Description: Vaguely emulates a writeroom-like environment in Vim by
"             splitting the current window in such a way as to center a column
"             of user-specified width, wrap the text, and break lines.
"Maintainer:  Henri Bourcereau <henri@rhumbs.fr>
"Version:     0.1
"Last Change: 2013-01-26
"License:     BSD <../LICENSE.markdown>
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

" The desired font. Defaults to Cousine 12
if !exists( "g:zenmode_font" )
  let g:zenmode_font ="Cousine 12"
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

" The GUI background color.  Defaults to "black"
if !exists( "g:zenmode_guibackground" )
    let g:zenmode_guibackground = "black"
endif

" The cterm background color.  Defaults to "bg"
if !exists( "g:zenmode_ctermbackground" )
    let g:zenmode_ctermbackground = "bg"
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

" Should Zenmode clear line numbers from the Zenmodeed buffer?  Defaults to `1`
" (on). Set to `0` if you'd prefer Zenmode to leave line numbers untouched.
" (Note that setting this to `0` will not turn line numbers on if they aren't
" on already).
if !exists( "g:zenmode_clear_line_numbers" )
    let g:zenmode_clear_line_numbers = 1
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
  exec "set gfn=".escape(g:zenmode_font,' ')
  if s:is_the_screen_wide_enough()
    let s:active = 1
    let s:sidebar = s:sidebar_size()
    " Turn off Powerline
    autocmd! Powerline

    " Turn off menus
    set guioptions=

    " Turn off status bar
    set statusline=

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
    if g:zenmode_clear_line_numbers
      set nonumber
      silent! set norelativenumber
    endif
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
      let l:highlightbgcolor = "guibg=" . g:zenmode_guibackground
      let l:highlightfgbgcolor = "guifg=" . g:zenmode_guibackground . " " . l:highlightbgcolor
    else
      let l:highlightbgcolor = "ctermbg=" . g:zenmode_ctermbackground
      let l:highlightfgbgcolor = "ctermfg=" . g:zenmode_ctermbackground . " " . l:highlightbgcolor
    endif
    exec( "hi Normal " . l:highlightbgcolor )
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
    nmap <silent> <Leader>V <Plug>ZenmodeToggle
endif
