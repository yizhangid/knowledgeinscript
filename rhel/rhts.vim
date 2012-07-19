" Vim synta file
" Language: beaker rhts log file
" Maintainer: Yi Zhang
" Version: 0.1
"
if exists("b:current_syntax")
    finish
endif

" Keywords
syn keyword pass PASS Passed OK matches
syn keyword fail FAIL Failed ABORT Abort
syn match   logcomment '^#.*'
syn match   log 'LOG.*'
syn match   logtime '\d\+:\d\+:\d\+'

let b:current_syntax = "rhtslog"
hi def link pass Type
hi def link fail Error
" hi def link log  Statement
hi def link log Comment
hi def link logcomment Comment
hi def link logtime Constant
