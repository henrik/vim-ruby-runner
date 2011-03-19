if exists("g:loaded_RubyRunner")
  finish
endif
let g:loaded_RubyRunner = 1


function! s:RunRuby()
  cd %:p:h  " Use file dir as pwd
  redir => m
  silent w ! ruby
  redir END
  cd -  " Back to old dir

  " Reuse or create new buffer. Based on code in Decho
  " http://www.vim.org/scripts/script.php?script_id=120
  if exists("t:rrbufnr") && bufwinnr(t:rrbufnr) > 0
    exe "keepjumps ".bufwinnr(t:rrbufnr)."wincmd W"
    exe 'normal ggdG'
  else
    exe "keepjumps silent! new"
    let t:rrbufnr=bufnr('%')
  end

  put=m
  " Fix Ctrl+M linefeeds.
  silent! %s/\r//
  " Fix extraneous leading blank lines.
  1,2d
  " Close on q
  map <buffer> q ZZ
  " Set a filetype so we can define more mappings elsewhere.
  set ft=ruby-runner
  " Make it a scratch (temporary) buffer.
  setlocal buftype=nofile bufhidden=wipe noswapfile
  " Store the buffer number so we can reuse it.
endfunction


command RunRuby call <SID>RunRuby()


if !hasmapto("RunRuby") && has("autocmd") && has("gui_macvim")

  " Unshifted
  au FileType ruby map  <buffer> <D-r>      :RunRuby<CR>
  au FileType ruby imap <buffer> <D-r> <Esc>:RunRuby<CR>

  " Shifted
  au FileType ruby map  <buffer> <D-R>      :RunRuby<CR> <C-w>w
  au FileType ruby imap <buffer> <D-R> <Esc>:RunRuby<CR> <C-w>wa

  " Close output buffer
  au FileType ruby-runner map <buffer> <D-r> ZZ

endif
