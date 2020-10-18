call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Basic support for a variety of languages
Plug 'sheerun/vim-polyglot'

" Navigate files easily
Plug 'lokaltog/vim-easymotion'

" Commenting
Plug 'tpope/vim-commentary'

" Git
Plug 'tpope/vim-fugitive'

" Session management
Plug 'tpope/vim-obsession'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Display diff symbols
Plug 'mhinz/vim-signify'

" FileTree navigator
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggleVCS' }

" Automatically set cwd
Plug 'airblade/vim-rooter'

call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"                       General options
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","
map <Leader> <Plug>(easymotion-prefix)

set hidden

set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Horizontal splits opens below
set splitbelow

" Vertical splits open to the right
set splitright

" Number of visual spaces per TAB
set tabstop=4

" Number of spaces in tab when editing
set softtabstop=4

" Number of columns text is indented with when reindenting using << or >>
set shiftwidth=4

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Don't highlight current line
set nocursorline

" Highlight matching [{()}]
set showmatch

" Use spaces instead of tabs
set expandtab

" Disable wrapping by default
set nowrap

" Open most folds by default
set foldlevelstart=10

" 10 nested fold max
set foldnestmax=10

" Fold based on indent level
set foldmethod=indent

" Disable swap files
set noswapfile

" No alarms and no surprises
set noerrorbells visualbell t_vb=

" Yank and paste with the system clipboard
set clipboard=unnamed

set wildignore+=node_modules/*,target/*

" Make searches case insensitive
set ignorecase

" Override ignorecase option if search contains uppercase characters
set smartcase

" Increase the size of file history
set viminfo='2000

" Always show the signcolumn, otherwise it would shift the text each time
" e file names as title of terminal while editing diagnostics appear/become resolved.
if has("patch-8.1.1564")
" Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"                                 COC
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<TAB>" :
\ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif


" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"                         General bindings
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Easier movement between windows
noremap <leader>wh <C-w>h
noremap <leader>wj <C-w>j
noremap <leader>wk <C-w>k
noremap <leader>wl <C-w>l


" Left and right can switch buffers
nnoremap <left> :bp<cr>
nnoremap <right> :bn<cr>


" Fzf
nnoremap <leader>? :Maps<cr>
nnoremap <leader>ss :BLines<cr>
nnoremap <leader>sS :Lines<cr>
nnoremap <leader>Ts :Colors<cr>
nnoremap <leader>pf :GFiles<cr>
nnoremap <leader>pp :RG<cr>
nnoremap <leader>tt :RG TODO<cr>
nnoremap <leader>tf :RG FIXME<cr>
nnoremap <leader>ff :Files ~/code<cr>

" NERDTreeToggleVCS
nnoremap <leader>pt :NERDTreeToggleVCS<cr>

let g:rustfmt_autosave = 1

nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gg :Git<space>

" Always enable preview window on the right with 60% width
let g:fzf_preview_window = 'right:60%'

autocmd! FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

set lazyredraw
