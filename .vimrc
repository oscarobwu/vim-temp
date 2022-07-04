" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
set ignorecase          " Do case insensitive matching
set smartcase           " Do smart case matching
set incsearch           " Incremental search
set autowrite           " Automatically save before commands like :next and :make
set hidden              " Hide buffers when they are abandoned
set mouse=a             " Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif








" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:   JiangMiao <jiangfriend@gmail.com>
" Contributor: camthompson
" Last Change:  2013-07-13
" Version: 1.3.2
" Homepage: http://www.vim.org/scripts/script.php?script_id=3599
" Repository: https://github.com/jiangmiao/auto-pairs
" License: MIT

if exists('g:AutoPairsLoaded') || &cp
  finish
end
let g:AutoPairsLoaded = 1

if !exists('g:AutoPairs')
  let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}
end

if !exists('g:AutoPairsParens')
  let g:AutoPairsParens = {'(':')', '[':']', '{':'}'}
end

if !exists('g:AutoPairsMapBS')
  let g:AutoPairsMapBS = 1
end

" Map <C-h> as the same BS
if !exists('g:AutoPairsMapCh')
  let g:AutoPairsMapCh = 1
end

if !exists('g:AutoPairsMapCR')
  let g:AutoPairsMapCR = 1
end

if !exists('g:AutoPairsMapSpace')
  let g:AutoPairsMapSpace = 1
end

if !exists('g:AutoPairsCenterLine')
  let g:AutoPairsCenterLine = 1
end

if !exists('g:AutoPairsShortcutToggle')
  let g:AutoPairsShortcutToggle = '<M-p>'
end

if !exists('g:AutoPairsShortcutFastWrap')
  let g:AutoPairsShortcutFastWrap = '<M-e>'
end

if !exists('g:AutoPairsShortcutJump')
  let g:AutoPairsShortcutJump = '<M-n>'
endif

" Fly mode will for closed pair to jump to closed pair instead of insert.
" also support AutoPairsBackInsert to insert pairs where jumped.
if !exists('g:AutoPairsFlyMode')
  let g:AutoPairsFlyMode = 0
endif

" When skipping the closed pair, look at the current and
" next line as well.
if !exists('g:AutoPairsMultilineClose')
  let g:AutoPairsMultilineClose = 1
endif

" Work with Fly Mode, insert pair where jumped
if !exists('g:AutoPairsShortcutBackInsert')
  let g:AutoPairsShortcutBackInsert = '<M-b>'
endif

if !exists('g:AutoPairsSmartQuotes')
  let g:AutoPairsSmartQuotes = 1
endif

" 7.4.849 support <C-G>U to avoid breaking '.'
" Issue talk: https://github.com/jiangmiao/auto-pairs/issues/3
" Vim note: https://github.com/vim/vim/releases/tag/v7.4.849
if v:version >= 704 && has("patch849")
  let s:Go = "\<C-G>U"
else
  let s:Go = ""
endif

let s:Left = s:Go."\<LEFT>"
let s:Right = s:Go."\<RIGHT>"

" Will auto generated {']' => '[', ..., '}' => '{'}in initialize.
let g:AutoPairsClosedPairs = {}

function! AutoPairsInsert(key)
  if !b:autopairs_enabled
    return a:key
  end

  let line = getline('.')
  let pos = col('.') - 1
  let before = strpart(line, 0, pos)
  let after = strpart(line, pos)
  let next_chars = split(after, '\zs')
  let current_char = get(next_chars, 0, '')
  let next_char = get(next_chars, 1, '')
  let prev_chars = split(before, '\zs')
  let prev_char = get(prev_chars, -1, '')

  let eol = 0
  if col('$') -  col('.') <= 1
    let eol = 1
  end

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " The key is difference open-pair, then it means only for ) ] } by default
  if !has_key(b:AutoPairs, a:key)
    let b:autopairs_saved_pair = [a:key, getpos('.')]

    " Skip the character if current character is the same as input
    if current_char == a:key
      return s:Right
    end

    if !g:AutoPairsFlyMode
      " Skip the character if next character is space
      if current_char == ' ' && next_char == a:key
        return s:Right.s:Right
      end

      " Skip the character if closed pair is next character
      if current_char == ''
        if g:AutoPairsMultilineClose
          let next_lineno = line('.')+1
          let next_line = getline(nextnonblank(next_lineno))
          let next_char = matchstr(next_line, '\s*\zs.')
        else
          let next_char = matchstr(line, '\s*\zs.')
        end
        if next_char == a:key
          return "\<ESC>e^a"
        endif
      endif
    endif

    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if g:AutoPairsFlyMode && has_key(b:AutoPairsClosedPairs, a:key)
      let n = stridx(after, a:key)
      if n != -1
        return repeat(s:Right, n+1)
      end
      if search(a:key, 'W')
        " force break the '.' when jump to different line
        return "\<Right>"
      endif
    endif

    " Insert directly if the key is not an open key
    return a:key
  end

  let open = a:key
  let close = b:AutoPairs[open]

  if current_char == close && open == close
    return s:Right
  end

  " Ignore auto close ' if follows a word
  " MUST after closed check. 'hello|'
  if a:key == "'" && prev_char =~ '\v\w'
    return a:key
  end

  " support for ''' ``` and """
  if open == close
    " The key must be ' " `
    let pprev_char = line[col('.')-3]
    if pprev_char == open && prev_char == open
      " Double pair found
      return repeat(a:key, 4) . repeat(s:Left, 3)
    end
  end

  let quotes_num = 0
  " Ignore comment line for vim file
  if &filetype == 'vim' && a:key == '"'
    if before =~ '^\s*$'
      return a:key
    end
    if before =~ '^\s*"'
      let quotes_num = -1
    end
  end

  " Keep quote number is odd.
  " Because quotes should be matched in the same line in most of situation
  if g:AutoPairsSmartQuotes && open == close
    " Remove \\ \" \'
    let cleaned_line = substitute(line, '\v(\\.)', '', 'g')
    let n = quotes_num
    let pos = 0
    while 1
      let pos = stridx(cleaned_line, open, pos)
      if pos == -1
        break
      end
      let n = n + 1
      let pos = pos + 1
    endwhile
    if n % 2 == 1
      return a:key
    endif
  endif

  return open.close.s:Left
endfunction

function! AutoPairsDelete()
  if !b:autopairs_enabled
    return "\<BS>"
  end

  let line = getline('.')
  let pos = col('.') - 1
  let current_char = get(split(strpart(line, pos), '\zs'), 0, '')
  let prev_chars = split(strpart(line, 0, pos), '\zs')
  let prev_char = get(prev_chars, -1, '')
  let pprev_char = get(prev_chars, -2, '')

  if pprev_char == '\'
    return "\<BS>"
  end

  " Delete last two spaces in parens, work with MapSpace
  if has_key(b:AutoPairs, pprev_char) && prev_char == ' ' && current_char == ' '
    return "\<BS>\<DEL>"
  endif

  " Delete Repeated Pair eg: '''|''' [[|]] {{|}}
  if has_key(b:AutoPairs, prev_char)
    let times = 0
    let p = -1
    while get(prev_chars, p, '') == prev_char
      let p = p - 1
      let times = times + 1
    endwhile

    let close = b:AutoPairs[prev_char]
    let left = repeat(prev_char, times)
    let right = repeat(close, times)

    let before = strpart(line, pos-times, times)
    let after  = strpart(line, pos, times)
    if left == before && right == after
      return repeat("\<BS>\<DEL>", times)
    end
  end

  if has_key(b:AutoPairs, prev_char)
    let close = b:AutoPairs[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      " Delete (|___)
      let space = matchstr(line, '^\s*', col('.')-1)
      return "\<BS>". repeat("\<DEL>", len(space)+1)
    elseif match(line, '^\s*$', col('.')-1) != -1
      " Delete (|__\n___)
      let nline = getline(line('.')+1)
      if nline =~ '^\s*'.close
        if &filetype == 'vim' && prev_char == '"'
          " Keep next line's comment
          return "\<BS>"
        end

        let space = matchstr(nline, '^\s*')
        return "\<BS>\<DEL>". repeat("\<DEL>", len(space)+1)
      end
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('["\]'')}]','W')
endfunction
" string_chunk cannot use standalone
let s:string_chunk = '\v%(\\\_.|[^\1]|[\r\n]){-}'
let s:ss_pattern = '\v''' . s:string_chunk . ''''
let s:ds_pattern = '\v"'  . s:string_chunk . '"'

func! s:RegexpQuote(str)
  return substitute(a:str, '\v[\[\{\(\<\>\)\}\]]', '\\&', 'g')
endf

func! s:RegexpQuoteInSquare(str)
  return substitute(a:str, '\v[\[\]]', '\\&', 'g')
endf

" Search next open or close pair
func! s:FormatChunk(open, close)
  let open = s:RegexpQuote(a:open)
  let close = s:RegexpQuote(a:close)
  let open2 = s:RegexpQuoteInSquare(a:open)
  let close2 = s:RegexpQuoteInSquare(a:close)
  if open == close
    return '\v'.open.s:string_chunk.close
  else
    return '\v%(' . s:ss_pattern . '|' . s:ds_pattern . '|' . '[^'.open2.close2.']|[\r\n]' . '){-}(['.open2.close2.'])'
  end
endf

" Fast wrap the word in brackets
function! AutoPairsFastWrap()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]
  let open_pair_pattern = '\v[({\[''"]'
  let at_end = col('.') >= col('$') - 1
  normal x
  " Skip blank
  if next_char =~ '\v\s' || at_end
    call search('\v\S', 'W')
    let line = getline('.')
    let next_char = line[col('.')-1]
  end

  if has_key(b:AutoPairs, next_char)
    let followed_open_pair = next_char
    let inputed_close_pair = current_char
    let followed_close_pair = b:AutoPairs[next_char]
    if followed_close_pair != followed_open_pair
      " TODO replace system searchpair to skip string and nested pair.
      " eg: (|){"hello}world"} will transform to ({"hello})world"}
      call searchpair('\V'.followed_open_pair, '', '\V'.followed_close_pair, 'W')
    else
      call search(s:FormatChunk(followed_open_pair, followed_close_pair), 'We')
    end
    return s:Right.inputed_close_pair.s:Left
  else
    normal he
    return s:Right.current_char.s:Left
  end
endfunction

function! AutoPairsMap(key)
  " | is special key which separate map command from text
  let key = a:key
  if key == '|'
    let key = '<BAR>'
  end
  let escaped_key = substitute(key, "'", "''", 'g')
  " use expr will cause search() doesn't work
  execute 'inoremap <buffer> <silent> '.key." <C-R>=AutoPairsInsert('".escaped_key."')<CR>"
endfunction

function! AutoPairsToggle()
  if b:autopairs_enabled
    let b:autopairs_enabled = 0
    echo 'AutoPairs Disabled.'
  else
    let b:autopairs_enabled = 1
    echo 'AutoPairs Enabled.'
  end
  return ''
endfunction

function! AutoPairsReturn()
  if b:autopairs_enabled == 0
    return ''
  end
  let line = getline('.')
  let pline = getline(line('.')-1)
  let prev_char = pline[strlen(pline)-1]
  let cmd = ''
  let cur_char = line[col('.')-1]
  if has_key(b:AutoPairs, prev_char) && b:AutoPairs[prev_char] == cur_char
    if g:AutoPairsCenterLine && winline() * 3 >= winheight(0) * 2
      " Use \<BS> instead of \<ESC>cl will cause the placeholder deleted
      " incorrect. because <C-O>zz won't leave Normal mode.
      " Use \<DEL> is a bit wierd. the character before cursor need to be deleted.
      " Adding a space, recentering, and deleting it interferes with default
      " whitespace-removing behavior when exiting insert mode.
      let cmd = "\<ESC>zzcc"
    end

    " If equalprg has been set, then avoid call =
    " https://github.com/jiangmiao/auto-pairs/issues/24
    if &equalprg != ''
      return "\<ESC>O".cmd
    endif

    " conflict with javascript and coffee
    " javascript   need   indent new line
    " coffeescript forbid indent new line
    if &filetype == 'coffeescript' || &filetype == 'coffee'
      return "\<ESC>k==o".cmd
    else
      return "\<ESC>=ko".cmd
    endif
  end
  return ''
endfunction

function! AutoPairsSpace()
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let cmd = ''
  let cur_char =line[col('.')-1]
  if has_key(g:AutoPairsParens, prev_char) && g:AutoPairsParens[prev_char] == cur_char
    let cmd = "\<SPACE>".s:Left
  endif
  return "\<SPACE>".cmd
endfunction

function! AutoPairsBackInsert()
  if exists('b:autopairs_saved_pair')
    let pair = b:autopairs_saved_pair[0]
    let pos  = b:autopairs_saved_pair[1]
    call setpos('.', pos)
    return pair
  endif
  return ''
endfunction

function! AutoPairsInit()
  let b:autopairs_loaded  = 1
  let b:autopairs_enabled = 1
  let b:AutoPairsClosedPairs = {}

  if !exists('b:AutoPairs')
    let b:AutoPairs = g:AutoPairs
  end

  " buffer level map pairs keys
  for [open, close] in items(b:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let b:AutoPairsClosedPairs[close] = open
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
  if g:AutoPairsMapBS
    " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
    execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'
  end

  if g:AutoPairsMapCh
    execute 'inoremap <buffer> <silent> <C-h> <C-R>=AutoPairsDelete()<CR>'
  endif

  if g:AutoPairsMapSpace
    " Try to respect abbreviations on a <SPACE>
    let do_abbrev = ""
    if v:version == 703 && has("patch489") || v:version > 703
      let do_abbrev = "<C-]>"
    endif
    execute 'inoremap <buffer> <silent> <SPACE> '.do_abbrev.'<C-R>=AutoPairsSpace()<CR>'
  end

  if g:AutoPairsShortcutFastWrap != ''
    execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutFastWrap.' <C-R>=AutoPairsFastWrap()<CR>'
  end

  if g:AutoPairsShortcutBackInsert != ''
    execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutBackInsert.' <C-R>=AutoPairsBackInsert()<CR>'
  end

  if g:AutoPairsShortcutToggle != ''
    " use <expr> to ensure showing the status when toggle
    execute 'inoremap <buffer> <silent> <expr> '.g:AutoPairsShortcutToggle.' AutoPairsToggle()'
    execute 'noremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' :call AutoPairsToggle()<CR>'
  end

  if g:AutoPairsShortcutJump != ''
    execute 'inoremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' <ESC>:call AutoPairsJump()<CR>a'
    execute 'noremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' :call AutoPairsJump()<CR>'
  end

endfunction

function! s:ExpandMap(map)
  let map = a:map
  let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  return map
endfunction

function! AutoPairsTryInit()
  if exists('b:autopairs_loaded')
    return
  end

  " for auto-pairs starts with 'a', so the priority is higher than supertab and vim-endwise
  "
  " vim-endwise doesn't support <Plug>AutoPairsReturn
  " when use <Plug>AutoPairsReturn will cause <Plug> isn't expanded
  "
  " supertab doesn't support <SID>AutoPairsReturn
  " when use <SID>AutoPairsReturn  will cause Duplicated <CR>
  "
  " and when load after vim-endwise will cause unexpected endwise inserted.
  " so always load AutoPairs at last

  " Buffer level keys mapping
  " comptible with other plugin
  if g:AutoPairsMapCR
    if v:version == 703 && has('patch32') || v:version > 703
      " VIM 7.3 supports advancer maparg which could get <expr> info
      " then auto-pairs could remap <CR> in any case.
      let info = maparg('<CR>', 'i', 0, 1)
      if empty(info)
        let old_cr = '<CR>'
        let is_expr = 0
      else
        let old_cr = info['rhs']
        let old_cr = s:ExpandMap(old_cr)
        let old_cr = substitute(old_cr, '<SID>', '<SNR>' . info['sid'] . '_', 'g')
        let is_expr = info['expr']
        let wrapper_name = '<SID>AutoPairsOldCRWrapper73'
      endif
    else
      " VIM version less than 7.3
      " the mapping's <expr> info is lost, so guess it is expr or not, it's
      " not accurate.
      let old_cr = maparg('<CR>', 'i')
      if old_cr == ''
        let old_cr = '<CR>'
        let is_expr = 0
      else
        let old_cr = s:ExpandMap(old_cr)
        " old_cr contain (, I guess the old cr is in expr mode
        let is_expr = old_cr =~ '\V(' && toupper(old_cr) !~ '\V<C-R>'

        " The old_cr start with " it must be in expr mode
        let is_expr = is_expr || old_cr =~ '\v^"'
        let wrapper_name = '<SID>AutoPairsOldCRWrapper'
      end
    end

    if old_cr !~ 'AutoPairsReturn'
      if is_expr
        " remap <expr> to `name` to avoid mix expr and non-expr mode
        execute 'inoremap <buffer> <expr> <script> '. wrapper_name . ' ' . old_cr
        let old_cr = wrapper_name
      end
      " Always silent mapping
      execute 'inoremap <script> <buffer> <silent> <CR> '.old_cr.'<SID>AutoPairsReturn'
    end
  endif
  call AutoPairsInit()
endfunction

" Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn

au BufEnter * :call AutoPairsTryInit()








" Vim color file
" Converted from Textmate theme Monokai using Coloration v0.3.2 (http://github.com/sickill/coloration)
set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
set t_Co=256
let g:colors_name = "monokai"
hi Cursor ctermfg=235 ctermbg=231 cterm=NONE guifg=#272822 guibg=#f8f8f0 gui=NONE
hi Visual ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#49483e gui=NONE
hi CursorLine ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
hi ColorColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
hi LineNr ctermfg=102 ctermbg=237 cterm=NONE guifg=#90908a guibg=#3c3d37 gui=NONE
hi VertSplit ctermfg=241 ctermbg=241 cterm=NONE guifg=#64645e guibg=#64645e gui=NONE
hi MatchParen ctermfg=197 ctermbg=NONE cterm=underline guifg=#f92672 guibg=NONE gui=underline
hi StatusLine ctermfg=231 ctermbg=241 cterm=bold guifg=#f8f8f2 guibg=#64645e gui=bold
hi StatusLineNC ctermfg=231 ctermbg=241 cterm=NONE guifg=#f8f8f2 guibg=#64645e gui=NONE
hi Pmenu ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi PmenuSel ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#49483e gui=NONE
hi IncSearch ctermfg=235 ctermbg=186 cterm=NONE guifg=#272822 guibg=#e6db74 gui=NONE
hi Search ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
hi Directory ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi Folded ctermfg=242 ctermbg=235 cterm=NONE guifg=#75715e guibg=#272822 gui=NONE
hi SignColumn ctermfg=NONE ctermbg=237 cterm=NONE guifg=NONE guibg=#3c3d37 gui=NONE
hi Normal ctermfg=231 ctermbg=235 cterm=NONE guifg=#f8f8f2 guibg=#272822 gui=NONE
hi Boolean ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi Character ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi Comment ctermfg=242 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
hi Conditional ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi Constant ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Define ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi DiffAdd ctermfg=231 ctermbg=64 cterm=bold guifg=#f8f8f2 guibg=#46830c gui=bold
hi DiffDelete ctermfg=88 ctermbg=NONE cterm=NONE guifg=#8b0807 guibg=NONE gui=NONE
hi DiffChange ctermfg=NONE ctermbg=NONE cterm=NONE guifg=#f8f8f2 guibg=#243955 gui=NONE
hi DiffText ctermfg=231 ctermbg=24 cterm=bold guifg=#f8f8f2 guibg=#204a87 gui=bold
hi ErrorMsg ctermfg=231 ctermbg=197 cterm=NONE guifg=#f8f8f0 guibg=#f92672 gui=NONE
hi WarningMsg ctermfg=231 ctermbg=197 cterm=NONE guifg=#f8f8f0 guibg=#f92672 gui=NONE
hi Float ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi Function ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi Identifier ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
hi Keyword ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi Label ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi NonText ctermfg=59 ctermbg=236 cterm=NONE guifg=#49483e guibg=#31322c gui=NONE
hi Number ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi Operator ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi PreProc ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi Special ctermfg=231 ctermbg=NONE cterm=NONE guifg=#f8f8f2 guibg=NONE gui=NONE
hi SpecialComment ctermfg=242 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
hi SpecialKey ctermfg=59 ctermbg=237 cterm=NONE guifg=#49483e guibg=#3c3d37 gui=NONE
hi Statement ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi StorageClass ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
hi String ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi Tag ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi Title ctermfg=231 ctermbg=NONE cterm=bold guifg=#f8f8f2 guibg=NONE gui=bold
hi Todo ctermfg=95 ctermbg=NONE cterm=inverse,bold guifg=#75715e guibg=NONE gui=inverse,bold
hi Type ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
hi rubyClass ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi rubyFunction ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi rubyInterpolationDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubySymbol ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi rubyConstant ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
hi rubyStringDelimiter ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi rubyBlockParameter ctermfg=208 ctermbg=NONE cterm=NONE guifg=#fd971f guibg=NONE gui=italic
hi rubyInstanceVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubyInclude ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi rubyGlobalVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubyRegexp ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi rubyRegexpDelimiter ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi rubyEscape ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi rubyControl ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi rubyClassVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubyOperator ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi rubyException ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi rubyPseudoVariable ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubyRailsUserClass ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
hi rubyRailsARAssociationMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi rubyRailsARMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi rubyRailsRenderMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi rubyRailsMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi erubyDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi erubyComment ctermfg=95 ctermbg=NONE cterm=NONE guifg=#75715e guibg=NONE gui=NONE
hi erubyRailsMethod ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi htmlTag ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi htmlEndTag ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi htmlTagName ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi htmlArg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi htmlSpecialChar ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi javaScriptFunction ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=italic
hi javaScriptRailsFunction ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi javaScriptBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlKey ctermfg=197 ctermbg=NONE cterm=NONE guifg=#f92672 guibg=NONE gui=NONE
hi yamlAnchor ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlAlias ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlDocumentHeader ctermfg=186 ctermbg=NONE cterm=NONE guifg=#e6db74 guibg=NONE gui=NONE
hi cssURL ctermfg=208 ctermbg=NONE cterm=NONE guifg=#fd971f guibg=NONE gui=italic
hi cssFunctionName ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi cssColor ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi cssPseudoClassId ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi cssClassName ctermfg=148 ctermbg=NONE cterm=NONE guifg=#a6e22e guibg=NONE gui=NONE
hi cssValueLength ctermfg=141 ctermbg=NONE cterm=NONE guifg=#ae81ff guibg=NONE gui=NONE
hi cssCommonAttr ctermfg=81 ctermbg=NONE cterm=NONE guifg=#66d9ef guibg=NONE gui=NONE
hi cssBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE








" @t0rr3sp3dr0 Pure
silent exec "!stty -ixon"
set autoindent
set autoread
set backspace=indent,eol,start
set cc=80
set clipboard=unnamed
set cursorline
set expandtab
set exrc
set laststatus=2
set nocompatible
set number
set pastetoggle=<F2>
set shiftwidth=4
set showcmd
set showmatch
set showmode
set smartindent
set smarttab
set softtabstop=0
set t_Co=256
set tabstop=8
set wildmenu
nmap <C-a> <Home>
imap <C-a> <Esc>I
vmap <C-a> <Home>
nmap <C-e> <End>
imap <C-e> <Esc>A
vmap <C-e> <End>
nmap <C-d> yyp
imap <C-d> <Esc>yypi
vmap <C-d> <Esc>yypv
nmap <C-s> :w<CR>
imap <C-s> <Esc>:w<CR>i
vmap <C-s> <Esc>:w<CR>v
nmap <C-w> :x<CR>
imap <C-w> <Esc>:x<CR>
vmap <C-w> <Esc>:x<CR>
nmap <C-q><Tab> :!killall -9 vim<CR>
imap <C-q><Tab> <Esc>:!killall -9 vim<CR>
vmap <C-q><Tab> <Esc>:!killall -9 vim<CR>
nmap <C-k> dd
imap <C-k> <Esc>ddi
vmap <C-k> <Esc>ddv
nmap <C-u> p
imap <C-u> <Esc>pi
vmap <C-u> <Esc>pv
nmap <C-t> :tabe<CR>
imap <C-t> <Esc>:tabe<CR>i
vmap <C-t> <Esc>:tabe<CR>v
nmap <C-\><C-[> :tabp<CR>
imap <C-\><C-[> <Esc>:tabp<CR>i
vmap <C-\><C-[> <Esc>:tabp<CR>v
nmap <C-\><C-]> :tabn<CR>
imap <C-\><C-]> <Esc>:tabn<CR>i
vmap <C-\><C-]> <Esc>:tabn<CR>v
nmap <C-c><C-p><C-p> <C-t>:setf cpp<CR>i#include <lt>bits/stdc++.h><CR><CR>using namespace std;<CR><CR>int main() {<CR>ios::sync_with_stdio(false);<CR><CR>return 0;<C-a><CR><Up><CR><Up>
imap <C-c><C-p><C-p> <C-t><Esc>:setf cpp<CR>i#include <lt>bits/stdc++.h><CR><CR>using namespace std;<CR><CR>int main() {<CR>ios::sync_with_stdio(false);<CR><CR>return 0;<C-a><CR><Up><CR><Up>
vmap <C-c><C-p><C-p> <C-t><Esc>:setf cpp<CR>i#include <lt>bits/stdc++.h><CR><CR>using namespace std;<CR><CR>int main() {<CR>ios::sync_with_stdio(false);<CR><CR>return 0;<C-a><CR><Up><CR><Up>
nmap <C-o><C-u> :tabe main.cpp<CR>
imap <C-o><C-u> <Esc> :tabe main.cpp<CR>i
vmap <C-o><C-u> <Esc> :tabe main.cpp<CR>v
nmap <C-o><C-i> :tabe in<CR>
imap <C-o><C-i> <Esc>:tabe in<CR>i
vmap <C-o><C-i> <Esc>:tabe in<CR>v
nmap <C-o><C-o> :tabe out<CR>
imap <C-o><C-o> <Esc>:tabe out<CR>i
vmap <C-o><C-o> <Esc>:tabe out<CR>v
nmap <C-o><C-p> :tabe diff<CR>
imap <C-o><C-p> <Esc>:tabe diff<CR>i
vmap <C-o><C-p> <Esc>:tabe diff<CR>v
nmap <F9> <C-s>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in<CR>
imap <F9> <C-s><Esc>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in<CR>
vmap <F9> <C-s><Esc>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in<CR>
nmap <F10> <C-s>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in > out && diff diff out<CR>
imap <F10> <C-s><Esc>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in > out && diff diff out<CR>
vmap <F10> <C-s><Esc>:!clear && clear && g++ -g -O2 -std=gnu++11 -static main.cpp && ./a.out < in > out && diff diff out<CR>
