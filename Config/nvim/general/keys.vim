" Better nav for omnicomplete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Move windows
map sh <C-w>h
map sk <C-w>k
map sj <C-w>j
map sl <C-w>l

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Split window
nmap ss :split<Return><C-w>w
nmap sv :vsplit<Return><C-w>w

" TAB in general mode will move to text buffer
nnoremap <TAB> :TablineBufferNext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :TablineBufferPrevious<CR>

" Select all
nmap <C-a> gg<S-v>G

" Executions
nnoremap <silent> <leader>r :!g++-11 -Wall % && ./a.out<cr>

nmap <leader>e :CocCommand explorer<CR>
