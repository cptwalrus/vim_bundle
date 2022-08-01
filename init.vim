syntax on

set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set nohlsearch
set scrolloff=8
set signcolumn=yes
set splitright
set splitbelow


"
" Give more space for displaying messages.
set cmdheight=2

set comments=s1:/*,mb:\ *,e1x:\ */

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set colorcolumn=120
highlight ColorColumn ctermbg=0 guibg=lightgrey



call plug#begin('~/.vim/plugged')

Plug 'gruvbox-community/gruvbox'

Plug 'mbbill/undotree'

Plug 'nvim-treesitter/nvim-treesitter'

"nvim-lsp stuff
Plug 'neovim/nvim-lspconfig'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

"Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'BurntSushi/ripgrep'

"vim debugging... maybe this is a bad idea?
Plug 'puremourning/vimspector'

"GLSL syntax
Plug 'tikhomirov/vim-glsl'

"Rust stuff
Plug 'rust-lang/rust.vim'

"Godot Stuff
Plug 'habamax/vim-godot'

call plug#end()

let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'

colorscheme gruvbox
set background=dark


"mappings
let mapleader = " "


"Block commenting
function BlockComment()
    let l:comment=split(&commentstring, '%s')
    if len(comment)==1
        call add(comment, '')
    endif
    let l:currMode=mode()
    if getline(".") =~ '^\s*'. l:comment[0]
        let l:commentLen = strchars(l:comment[0])
        let l:normalMatch = ':s/^.\{' . l:commentLen . '}//'
        let l:visualMatch = ":'<,'>s/^.\{" . l:commentLen . '}//'
        if l:currMode == "V"
            :execute l:visualMatch
        elseif l:currMode == "n"
            :execute l:normalMatch
        endif
    else
        if l:currMode == "V"
            :'<,'>s/^/\=l:comment[0]/
        elseif l:currMode == "n"
            :s/^/\=l:comment[0]/
        endif
    endif
endfunction

noremap <leader>c :call BlockComment()<CR>


"Terminal
"This will probably not work on normal vim
nnoremap <leader>t :vert term://bash<CR>  
nnoremap <leader>t :terminal<CR>
tnoremap <Esc> <C-\><C-n>

"undo tree and split resizing
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>

"vimspector mappings
let g:vimspector_enable_mappings = 'HUMAN'
nnoremap <silent> <leader><F10> :call vimspector#StepInto()<CR>
nnoremap <silent> <leader><F5> :call vimspector#LaunchWithSettings( #{ configuration: 'Default' } )<CR>
nnoremap <leader><F4> :VimspectorReset<CR>
nnoremap <leader>w :VimspectorWatch<space> 

"Telescope settings
let g:telescope_cache_results = 1
let g:telescope_prime_fuzzy_find = 1
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>

nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>

"LSP stuff shamelessly stolen from ThePrimeagen
nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>vsd :lua vim.lsp.util.show_line_diagnostics(); vim.lsp.util.show_line_diagnostics()<CR>
nnoremap <leader>vn :lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <leader>vll :call LspLocationList()<CR>

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

lua <<EOF
-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
    vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
end,
},
    mapping = {
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
        }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
sources = cmp.config.sources({
{ name = 'nvim_lsp' },
{ name = 'vsnip' }, -- For vsnip users.
-- { name = 'luasnip' }, -- For luasnip users.
-- { name = 'ultisnips' }, -- For ultisnips users.
-- { name = 'snippy' }, -- For snippy users.
}, {
{ name = 'buffer' },
})
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
      sources = {
          { name = 'buffer' }
          }
      })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
      sources = cmp.config.sources({
      { name = 'path' }
      }, {
      { name = 'cmdline' }
      })
  })

  -- Setup lspconfig.
  local servers = { 'clangd', 'rust_analyzer', 'pylsp', 'tsserver', 'gdscript' }
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  for _, lsp in ipairs(servers) do

      require('lspconfig')[lsp].setup {
          capabilities = capabilities
          }
  end
EOF
