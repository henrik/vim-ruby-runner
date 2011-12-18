if exists('g:loaded_RubyRunner')
  finish
endif
let g:loaded_RubyRunner = 1

if has('gui_running')
  let g:RubyRunner_key = '<D-r>'
  let g:RubyRunner_keep_focus_key = '<D-R>'
else
  let g:RubyRunner_key = '<Leader>r'
  let g:RubyRunner_keep_focus_key = '<Leader>R'
end

if (!exists("g:RubyRunner_open_below"))
  let g:RubyRunner_open_below = 0
endif

let s:output_file = '/tmp/ruby_runner_output.txt'

function! s:RunRuby()
  cd %:p:h  " Use file dir as pwd
  exec 'silent w ! ruby >' s:output_file
  cd -  " Back to old dir

  " Reuse or create new buffer. Based on code in Decho
  " http://www.vim.org/scripts/script.php?script_id=120
  if exists('t:rrbufnr') && bufwinnr(t:rrbufnr) > 0
    exec 'keepjumps' bufwinnr(t:rrbufnr) 'wincmd W'
    exec 'normal ggdG'
  else
    exec 'keepjumps silent!' (g:RubyRunner_open_below == 1 ? 'below' : '') 'new'
    let t:rrbufnr=bufnr('%')
  end

  exec 'read' s:output_file
  " Fix extraneous leading blank line.
  1d
  " Close on q.
  map <buffer> q ZZ
  " Set a filetype so we can define more mappings elsewhere.
  set ft=ruby-runner
  " Make it a scratch (temporary) buffer.
  setlocal buftype=nofile bufhidden=wipe noswapfile
endfunction


command! RunRuby call <SID>RunRuby()

if !hasmapto('RunRuby') && has('autocmd')

  " Unshifted
  exec 'au FileType ruby map  <buffer>' g:RubyRunner_key '     :RunRuby<CR>'
  exec 'au FileType ruby imap <buffer>' g:RubyRunner_key '<Esc>:RunRuby<CR>'

  " Shifted
  exec 'au FileType ruby map  <buffer>' g:RubyRunner_keep_focus_key ':RunRuby<CR> <C-w>w'
  exec 'au FileType ruby imap <buffer>' g:RubyRunner_keep_focus_key '<Esc>:RunRuby<CR> <C-w>wa'

  " Close output buffer
  exec 'au FileType ruby-runner map <buffer>' g:RubyRunner_key 'ZZ'

endif
