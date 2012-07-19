if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    " local filetype changes 
    au BufRead,BufNewFile *.rhts setfiletype rhts
augroup END
