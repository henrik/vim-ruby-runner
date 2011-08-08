if exists("g:loaded_RubyRunner")
  finish
endif
let g:loaded_RubyRunner = 1
let g:RubyRunner_key = '<Leader>r'
let g:RubyRunner_keep_focus_key = '<Leader>R'

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

if has("gui_macvim")
  let g:RubyRunner_key = '<D-r>'
  let g:RubyRunner_keep_focus_key = '<D-R>'
end

if !hasmapto("RunRuby") && has("autocmd") && has ("gui")
  " Unshifted
  exec 'au FileType ruby map  <buffer> ' . g:RubyRunner_key . '     :RunRuby<CR>'
  exec 'au FileType ruby imap <buffer> ' . g:RubyRunner_key . ' <Esc>:RunRuby<CR>'

  " Shifted
  exec 'au FileType ruby map  <buffer> ' . g:RubyRunner_keep_focus_key . ' :RunRuby<CR> <C-w>w'
  exec 'au FileType ruby imap <buffer> ' . g:RubyRunner_keep_focus_key . ' <Esc>:RunRuby<CR> <C-w>wa'

  " Close output buffer
  exec 'au FileType ruby-runner map <buffer> ' . g:RubyRunner_key . ' ZZ'

endif
