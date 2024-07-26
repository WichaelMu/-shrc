

nmap <silent> <C-N> :cn<CR>zv
nmap <silent> <C-P> :cp<CR>zv

" Define a custom function to open a terminal on the right side
function! OpenTerminalRight()
  " Close all other windows except the current one
  only

  " Split the window vertically
  vsplit

  " Move to the right window
  wincmd l

  " Open terminal in the right window
  terminal

  wincmd j
  wincmd c

  " Adjust window sizes equally
  wincmd =
endfunction

" Define a custom command :T to call the function
command! T call OpenTerminalRight()

command! -range=% C silent! execute 'normal! "+y'<CR>
xmap <silent> <Leader>c :C<CR>
nmap <silent> <Leader>c :'<,'>C<CR>
