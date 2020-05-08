" easyescapeplus.vim        Pull out your Escape key!
" Author:               Yu Hou
" Version:              0.2
" ---------------------------------------------------------------------
" Special Thanks to (Yichao Zhou) the author of easyescape.vim


if &cp || exists("g:loaded_easyescape")
    finish
endif
let g:loaded_easyescape = 1

if !exists("g:easyescape_string")
    let g:easyescape_string = "kj"
endif

if !exists("g:easyescape_timeout")
    let g:easyescape_timeout = 2000
endif

function! s:EasyescapeSetTimer()
    let s:localtime = reltime()
endfunction

function! s:EasyescapeReadTimer()
    return 1000 * reltimefloat(reltime(s:localtime))
endfunction


let s:started = 0
function! <SID>EasyescapeMapStart(char)
    let s:started = 1
    call s:EasyescapeSetTimer()
    return a:char
endfunction

function! <SID>EasyescapeMapEnd(char)
    if s:started == 0
        return a:char
    endif
    let s:started = 0

    if s:EasyescapeReadTimer() > g:easyescape_timeout
        let b:edited = 1
        call s:EasyescapeSetTimer()
        return a:char
    endif

    let l:line_check_empty = getline(".")
    if l:line_check_empty == "k"
        return s:escape_sequence
    endif

    let l:trimed  = substitute(l:line_check_empty, '^\s*\(.\{-}\)\s*$', '\1', '')
    if l:trimed == "k"
        return "\<BS>" . "\<c-w>" . "\<ESC>"
    else
        return s:escape_sequence
    endif
endfunction

let s:easyescape_start_key = g:easyescape_string[0]
let s:easyescape_end_key = g:easyescape_string[1]
let s:escape_sequence = "\<BS>" . "\<ESC>"
exec "inoremap <expr>" . s:easyescape_start_key . " <SID>EasyescapeMapStart(\"" . s:easyescape_start_key . "\")"
exec "inoremap <expr>" . s:easyescape_end_key . " <SID>EasyescapeMapEnd(\"" . s:easyescape_end_key . "\")"

function! s:EasyescapeInsertCharPre()
    if v:char != s:easyescape_start_key && v:char != s:easyescape_end_key
        let b:edited = 1
    endif
endfunction

function! s:EasyescapeInsertLeave()
    if b:edited == 0
        call setbufvar(bufnr("%"), "&mod", 0)
    endif
endfunction

function! s:EasyescapeInsertEnter()
    let b:edited = getbufvar(bufnr("%"), "&mod")
endfunction

augroup easyescape_plus
    au!
    au InsertCharPre * call s:EasyescapeInsertCharPre()
    au InsertLeave * call s:EasyescapeInsertLeave()
    au InsertEnter * call s:EasyescapeInsertEnter()
augroup END

let s:localtime = reltime()
