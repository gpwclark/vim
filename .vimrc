scriptencoding utf-8
" ^^ Please leave the above line at the start of the file.
"
set t_Co=256

"" ColorScheme {{{
colorscheme desert
set background=dark
"" }}}


" Default configuration file for Vim
" $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/files/vimrc-r4,v 1.3 2010/04/15 19:30:32 darkside Exp $

" Written by Aron Griffis <agriffis@gentoo.org>
" Modified by Ryan Phillips <rphillips@gentoo.org>
" Modified some more by Ciaran McCreesh <ciaranm@gentoo.org>
" Added Redhat's vimrc info by Seemant Kulleen <seemant@gentoo.org>

" You can override any of these settings on a global basis via the
" "/etc/vim/vimrc.local" file, and on a per-user basis via "~/.vimrc.local". You may
" need to create these.

" {{{ General settings
" The following are some sensible defaults for Vim for most users.
" We attempt to change as little as possible from Vim's defaults,
" deviating only where it makes sense
set bs=2                " Allow backspacing over everything in insert mode
set ai                  " Always set auto-indenting on
set history=70          " keep 50 lines of command history
set ruler               " Show the cursor position all the time

set viminfo='20,\"500   " Keep a .viminfo file.

" Don't use Ex mode, use Q for formatting
map Q gq

" When doing tab completion, give the following files lower priority. You may
" wish to set 'wildignore' to completely ignore files, and 'wildmenu' to enable
" enhanced tab completion. These can be done in the user vimrc file.
set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo

" When displaying line numbers, don't use an annoyingly wide number column. This
" doesn't enable line numbers -- :set number will do that. The value given is a
" minimum width to use for the number column, not a fixed size.
if v:version >= 700
  set numberwidth=4
endif
set number
" }}}

" {{{ Modeline settings
" We don't allow modelines by default. See bug #14088 and bug #73715.
" If you're not concerned about these, you can enable them on a per-user
" basis by adding "set modeline" to your ~/.vimrc file.
set nomodeline
" }}}

" {{{ Locale settings
" Try to come up with some nice sane GUI fonts. Also try to set a sensible
" value for fileencodings based upon locale. These can all be overridden in
" the user vimrc file.
if v:lang =~? "^ko"
  set fileencodings=euc-kr
  set guifontset=-*-*-medium-r-normal--16-*-*-*-*-*-*-*
elseif v:lang =~? "^ja_JP"
  set fileencodings=euc-jp
  set guifontset=-misc-fixed-medium-r-normal--14-*-*-*-*-*-*-*
elseif v:lang =~? "^zh_TW"
  set fileencodings=big5
  set guifontset=-sony-fixed-medium-r-normal--16-150-75-75-c-80-iso8859-1,-taipei-fixed-medium-r-normal--16-150-75-75-c-160-big5-0
elseif v:lang =~? "^zh_CN"
  set fileencodings=gb2312
  set guifontset=*-r-*
endif

" If we have a BOM, always honour that rather than trying to guess.
if &fileencodings !~? "ucs-bom"
  set fileencodings^=ucs-bom
endif

" Always check for UTF-8 when trying to determine encodings.
if &fileencodings !~? "utf-8"
  " If we have to add this, the default encoding is not Unicode.
  " We use this fact later to revert to the default encoding in plaintext/empty
  " files.
  let g:added_fenc_utf8 = 1
  set fileencodings+=utf-8
endif

" Make sure we have a sane fallback for encoding detection
if &fileencodings !~? "default"
  set fileencodings+=default
endif
" }}}

" {{{ Syntax highlighting settings
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
" }}}

" {{{ Terminal fixes
if &term ==? "xterm"
  set t_Sb=^[4%dm
  set t_Sf=^[3%dm
  set ttymouse=xterm2
endif

if &term ==? "gnome" && has("eval")
  " Set useful keys that vim doesn't discover via termcap but are in the
  " builtin xterm termcap. See bug #122562. We use exec to avoid having to
  " include raw escapes in the file.
  exec "set <C-Left>=\eO5D"
  exec "set <C-Right>=\eO5C"
endif
" }}}

" {{{ Filetype plugin settings
" Enable plugin-provided filetype settings, but only if the ftplugin
" directory exists (which it won't on livecds, for example).
if isdirectory(expand("$VIMRUNTIME/ftplugin"))
  filetype plugin on

  " Uncomment the next line (or copy to your ~/.vimrc) for plugin-provided
  " indent settings. Some people don't like these, so we won't turn them on by
  " default.
  " filetype indent on
endif
" }}}

" {{{ Fix &shell, see bug #101665.
if "" == &shell
  if executable("/bin/bash")
    set shell=/bin/bash
  elseif executable("/bin/sh")
    set shell=/bin/sh
  endif
endif
"}}}

" {{{ Our default /bin/sh is bash, not ksh, so syntax highlighting for .sh
" files should default to bash. See :help sh-syntax and bug #101819.
if has("eval")
  let is_bash=1
endif
" }}}

" {{{ Autocommands
if has("autocmd")

augroup gentoo
  au!

  " Gentoo-specific settings for ebuilds.  These are the federally-mandated
  " required tab settings.  See the following for more information:
  " http://www.gentoo.org/proj/en/devrel/handbook/handbook.xml
  " Note that the rules below are very minimal and don't cover everything.
  " Better to emerge app-vim/gentoo-syntax, which provides full syntax,
  " filetype and indent settings for all things Gentoo.
  au BufRead,BufNewFile *.e{build,class} let is_bash=1|setfiletype sh
  au BufRead,BufNewFile *.e{build,class} set ts=4 sw=4 noexpandtab

  " In text files, limit the width of text to 78 characters, but be careful
  " that we don't override the user's setting.
  autocmd BufNewFile,BufRead *.txt
        \ if &tw == 0 && ! exists("g:leave_my_textwidth_alone") |
        \     setlocal textwidth=78 |
        \ endif

  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
        \ if ! exists("g:leave_my_cursor_position_alone") |
        \     if line("'\"") > 0 && line ("'\"") <= line("$") |
        \         exe "normal g'\"" |
        \     endif |
        \ endif

  " When editing a crontab file, set backupcopy to yes rather than auto. See
  " :help crontab and bug #53437.
  autocmd FileType crontab set backupcopy=yes

  " If we previously detected that the default encoding is not UTF-8
  " (g:added_fenc_utf8), assume that a file with only ASCII characters (or no
  " characters at all) isn't a Unicode file, but is in the default encoding.
  " Except of course if a byte-order mark is in effect.
  autocmd BufReadPost *
        \ if exists("g:added_fenc_utf8") && &fileencoding == "utf-8" &&
        \    ! &bomb && search('[\x80-\xFF]','nw') == 0 && &modifiable |
        \       set fileencoding= |
        \ endif

augroup END

endif " has("autocmd")
" }}}

" {{{ vimrc.local
if filereadable(glob("~/.vimrc.local"))
	source ~/.vimrc.local
endif
" }}}

