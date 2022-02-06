# This is my dev environment

# docker pull alpine
# docker build -t mimc/alpine-dev:1.0 . && export IMAGE_SHA=$(docker create -it --entrypoint=/bin/bash mimc/alpine-dev:1.0) && docker start $IMAGE_SHA && docker attach $IMAGE_SHA ; docker container rm $IMAGE_SHA && docker image rm mimc/alpine-dev:1.0
FROM alpine

RUN apk update && \
apk add sudo bash gcc g++ make cmake git tmux perl curl vim the_silver_searcher ctags clang clang-extra-tools nodejs npm build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev && \
apk add cscope --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
addgroup -S gamers && adduser -S mike -G gamers -s /usr/bash && \
adduser mike wheel && \
sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

USER mike

# Clone some repos to test compiler and vim with
RUN cd /home/mike && git clone https://github.com/libretro/libretro-super && \
cd libretro-super && ./libretro-fetch.sh retroarch && cd retroarch && cscope -Rb && cd /home/mike && \
git clone https://github.com/neovim/neovim && cd neovim && make && sudo make install

RUN cd /home/mike && sudo apk add fzf fzf-bash-completion fzf-vim && \
echo "source /usr/share/fzf/key-bindings.bash"         >> .bashrc && \
echo 'colors() {'                                      >> .bashrc && \
echo '  for i in {0..255}; do'                         >> .bashrc && \
echo '    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"' >> .bashrc && \
echo '  done'                                          >> .bashrc && \
echo '}'                                               >> .bashrc && \
echo "cd $HOME"                                        >> .bashrc && \
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
echo 'call plug#begin()'                                      >> .vimrc && \
echo ''                                                       >> .vimrc && \
echo "Plug 'mg979/vim-visual-multi'"                          >> .vimrc && \
echo "Plug 'junegunn/fzf'"                                    >> .vimrc && \
echo "Plug 'junegunn/fzf.vim'"                                >> .vimrc && \
echo "Plug 'vim-scripts/taglist.vim'"                         >> .vimrc && \
echo "Plug 'joe-skb7/cscope-maps'"                            >> .vimrc && \
echo "if !has('nvim')"                                        >> .vimrc && \
echo "Plug 'neoclide/coc.nvim', {'branch': 'release'}"        >> .vimrc && \
echo 'endif'                                                  >> .vimrc && \
echo "Plug 'flazz/vim-colorschemes'"                          >> .vimrc && \
echo "Plug 'rafi/awesome-vim-colorschemes'"                   >> .vimrc && \
echo "if has('nvim')"                                         >> .vimrc && \
echo "Plug 'nvim-lua/plenary.nvim'"                           >> .vimrc && \
echo "Plug 'nvim-telescope/telescope.nvim'"                   >> .vimrc && \
echo "endif"                                                  >> .vimrc && \
echo ''                                                       >> .vimrc && \
echo 'call plug#end()'                                        >> .vimrc && \
echo ''                                                       >> .vimrc && \
echo 'set nowrap'                                             >> .vimrc && \
echo 'imap jk <Esc>'                                          >> .vimrc && \
echo 'syntax on'                                              >> .vimrc && \
echo 'set tabstop=8'                                          >> .vimrc && \
echo 'set softtabstop=2'                                      >> .vimrc && \
echo 'set shiftwidth=2'                                       >> .vimrc && \
echo 'set backspace=indent,eol,start'                         >> .vimrc && \
echo '"t_Co=256'                                              >> .vimrc && \
echo 'set termguicolors'                                      >> .vimrc && \
echo 'if exists('"'"'$TMUX'"'"')'                             >> .vimrc && \
echo '  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"'               >> .vimrc && \
echo '  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"'               >> .vimrc && \
echo 'endif'                                                  >> .vimrc && \
vim +'PlugInstall --sync' +qa                                 && \
mkdir -p /home/mike/.config/coc                               && \
vim +'CocInstall coc-json --sync' +qa                         && \
vim +'CocInstall coc-clangd --sync' +qa                       && \
echo '{'                                                      >> .vim/coc-settings.json && \
echo '  "languageserver":'                                    >> .vim/coc-settings.json && \
echo '  {'                                                    >> .vim/coc-settings.json && \
echo '    "clangd":'                                          >> .vim/coc-settings.json && \
echo '    {'                                                  >> .vim/coc-settings.json && \
echo '      "command": "clangd",'                             >> .vim/coc-settings.json && \
echo '      "rootPatterns": ["compile_flags.txt",'            >> .vim/coc-settings.json && \
echo '        "compile_commands.json"],'                      >> .vim/coc-settings.json && \
echo '        "filetypes":["c",'                              >> .vim/coc-settings.json && \
echo '          "cc",'                                        >> .vim/coc-settings.json && \
echo '          "cpp",'                                       >> .vim/coc-settings.json && \
echo '          "c++",'                                       >> .vim/coc-settings.json && \
echo '          "objc",'                                      >> .vim/coc-settings.json && \
echo '          "objcpp"]'                                    >> .vim/coc-settings.json && \
echo '    }'                                                  >> .vim/coc-settings.json && \
echo '  }'                                                    >> .vim/coc-settings.json && \
echo '}'                                                      >> .vim/coc-settings.json && \
echo '" Set internal encoding of vim, not needed on neovim, since coc.nvim using some'       >> .vimrc && \
echo '" unicode characters in the file autoload/float.vim'                                   >> .vimrc && \
echo 'set encoding=utf-8'                                                                    >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo "if !has('nvim')"                                                                       >> .vimrc && \
echo '" TextEdit might fail if hidden is not set.'                                           >> .vimrc && \
echo 'set hidden'                                                                            >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Some servers have issues with backup files, see #649.'                               >> .vimrc && \
echo 'set nobackup'                                                                          >> .vimrc && \
echo 'set nowritebackup'                                                                     >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Give more space for displaying messages.'                                            >> .vimrc && \
echo 'set cmdheight=2'                                                                       >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable'             >> .vimrc && \
echo '" delays and poor user experience.'                                                    >> .vimrc && \
echo 'set updatetime=300'                                                                    >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '"'" Don't pass messages to |ins-completion-menu|."                                     >> .vimrc && \
echo 'set shortmess+=c'                                                                      >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Always show the signcolumn, otherwise it would shift the text each time'             >> .vimrc && \
echo '" diagnostics appear/become resolved.'                                                 >> .vimrc && \
echo 'if has("nvim-0.5.0") || has("patch-8.1.1564")'                                         >> .vimrc && \
echo '  " Recently vim can merge signcolumn and number column into one'                      >> .vimrc && \
echo '  set signcolumn=number'                                                               >> .vimrc && \
echo 'else'                                                                                  >> .vimrc && \
echo '  set signcolumn=yes'                                                                  >> .vimrc && \
echo 'endif'                                                                                 >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Use tab for trigger completion with characters ahead and navigate.'                  >> .vimrc && \
echo '"'" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by"         >> .vimrc && \
echo '" other plugin before putting this into your config.'                                  >> .vimrc && \
echo 'inoremap <silent><expr> <TAB>'                                                         >> .vimrc && \
echo '      \ pumvisible() ? "\<C-n>" :'                                                     >> .vimrc && \
echo '      \ <SID>check_back_space() ? "\<TAB>" :'                                          >> .vimrc && \
echo '      \ coc#refresh()'                                                                 >> .vimrc && \
echo 'inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"'                             >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo 'function! s:check_back_space() abort'                                                  >> .vimrc && \
echo "  let col = col('.') - 1"                                                              >> .vimrc && \
echo "  return !col || getline('.')[col - 1]  =~# '\s'"                                      >> .vimrc && \
echo 'endfunction'                                                                           >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Use <c-space> to trigger completion.'                                                >> .vimrc && \
echo "if has('nvim')"                                                                        >> .vimrc && \
echo '  inoremap <silent><expr> <c-space> coc#refresh()'                                     >> .vimrc && \
echo 'else'                                                                                  >> .vimrc && \
echo '  inoremap <silent><expr> <c-@> coc#refresh()'                                         >> .vimrc && \
echo 'endif'                                                                                 >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Make <CR> auto-select the first completion item and notify coc.nvim to'              >> .vimrc && \
echo '" format on enter, <cr> could be remapped by other vim plugin'                         >> .vimrc && \
echo 'inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()'                     >> .vimrc && \
echo '                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"'             >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Use `[g` and `]g` to navigate diagnostics'                                           >> .vimrc && \
echo '" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.'    >> .vimrc && \
echo 'nmap <silent> [g <Plug>(coc-diagnostic-prev)'                                          >> .vimrc && \
echo 'nmap <silent> ]g <Plug>(coc-diagnostic-next)'                                          >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" GoTo code navigation.'                                                               >> .vimrc && \
echo 'nmap <silent> gd <Plug>(coc-definition)'                                               >> .vimrc && \
echo 'nmap <silent> gy <Plug>(coc-type-definition)'                                          >> .vimrc && \
echo 'nmap <silent> gi <Plug>(coc-implementation)'                                           >> .vimrc && \
echo 'nmap <silent> gr <Plug>(coc-references)'                                               >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Use K to show documentation in preview window.'                                      >> .vimrc && \
echo 'nnoremap <silent> K :call <SID>show_documentation()<CR>'                               >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo 'function! s:show_documentation()'                                                      >> .vimrc && \
echo "  if (index(['vim','help'], &filetype) >= 0)"                                          >> .vimrc && \
echo "    execute 'h '.expand('<cword>')"                                                    >> .vimrc && \
echo '  elseif (coc#rpc#ready())'                                                            >> .vimrc && \
echo "    call CocActionAsync('doHover')"                                                    >> .vimrc && \
echo '  else'                                                                                >> .vimrc && \
echo "    execute '!' . &keywordprg . "'" "'" . expand('<cword>')"                           >> .vimrc && \
echo '  endif'                                                                               >> .vimrc && \
echo 'endfunction'                                                                           >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Highlight the symbol and its references when holding the cursor.'                    >> .vimrc && \
echo "autocmd CursorHold * silent call CocActionAsync('highlight')"                          >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Symbol renaming.'                                                                    >> .vimrc && \
echo 'nmap <leader>rn <Plug>(coc-rename)'                                                    >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Formatting selected code.'                                                           >> .vimrc && \
echo 'xmap <leader>f  <Plug>(coc-format-selected)'                                           >> .vimrc && \
echo 'nmap <leader>f  <Plug>(coc-format-selected)'                                           >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo 'augroup mygroup'                                                                       >> .vimrc && \
echo '  autocmd!'                                                                            >> .vimrc && \
echo '  " Setup formatexpr specified filetype(s).'                                           >> .vimrc && \
echo "  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')"        >> .vimrc && \
echo '  " Update signature help on jump placeholder.'                                        >> .vimrc && \
echo "  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')"            >> .vimrc && \
echo 'augroup end'                                                                           >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Applying codeAction to the selected region.'                                         >> .vimrc && \
echo '" Example: `<leader>aap` for current paragraph'                                        >> .vimrc && \
echo 'xmap <leader>a  <Plug>(coc-codeaction-selected)'                                       >> .vimrc && \
echo 'nmap <leader>a  <Plug>(coc-codeaction-selected)'                                       >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Remap keys for applying codeAction to the current buffer.'                           >> .vimrc && \
echo 'nmap <leader>ac  <Plug>(coc-codeaction)'                                               >> .vimrc && \
echo '" Apply AutoFix to problem on the current line.'                                       >> .vimrc && \
echo 'nmap <leader>qf  <Plug>(coc-fix-current)'                                              >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Run the Code Lens action on the current line.'                                       >> .vimrc && \
echo 'nmap <leader>cl  <Plug>(coc-codelens-action)'                                          >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Map function and class text objects'                                                 >> .vimrc && \
echo '"'" NOTE: Requires 'textDocument.documentSymbol' support from the language server."    >> .vimrc && \
echo 'xmap if <Plug>(coc-funcobj-i)'                                                         >> .vimrc && \
echo 'omap if <Plug>(coc-funcobj-i)'                                                         >> .vimrc && \
echo 'xmap af <Plug>(coc-funcobj-a)'                                                         >> .vimrc && \
echo 'omap af <Plug>(coc-funcobj-a)'                                                         >> .vimrc && \
echo 'xmap ic <Plug>(coc-classobj-i)'                                                        >> .vimrc && \
echo 'omap ic <Plug>(coc-classobj-i)'                                                        >> .vimrc && \
echo 'xmap ac <Plug>(coc-classobj-a)'                                                        >> .vimrc && \
echo 'omap ac <Plug>(coc-classobj-a)'                                                        >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Remap <C-f> and <C-b> for scroll float windows/popups.'                              >> .vimrc && \
echo "if has('nvim-0.4.0') || has('patch-8.2.0750')"                                         >> .vimrc && \
echo '  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"'  >> .vimrc && \
echo '  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"'  >> .vimrc && \
echo '  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"'  >> .vimrc && \
echo '  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"'  >> .vimrc && \
echo '  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"'  >> .vimrc && \
echo '  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"'  >> .vimrc && \
echo 'endif'                                                                                 >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Use CTRL-S for selections ranges.'                                                   >> .vimrc && \
echo '"'" Requires 'textDocument/selectionRange' support of language server."                >> .vimrc && \
echo 'nmap <silent> <C-s> <Plug>(coc-range-select)'                                          >> .vimrc && \
echo 'xmap <silent> <C-s> <Plug>(coc-range-select)'                                          >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Add `:Format` command to format current buffer.'                                     >> .vimrc && \
echo 'command! -nargs=0 Format :call CocActionAsync('format')'                               >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Add `:Fold` command to fold current buffer.'                                         >> .vimrc && \
echo "command! -nargs=? Fold :call     CocAction('fold', <f-args>)"                          >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Add `:OR` command for organize imports of the current buffer.'                       >> .vimrc && \
echo "command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')" >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '"'" Add (Neo)Vim's native statusline support."                                         >> .vimrc && \
echo '" NOTE: Please see `:h coc-status` for integrations with external plugins that'        >> .vimrc && \
echo '" provide custom statusline: lightline.vim, vim-airline.'                              >> .vimrc && \
echo "set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}"                   >> .vimrc && \
echo ''                                                                                      >> .vimrc && \
echo '" Mappings for CoCList'                                                                >> .vimrc && \
echo '" Show all diagnostics.'                                                               >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>'                     >> .vimrc && \
echo '" Manage extensions.'                                                                  >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>'                      >> .vimrc && \
echo '" Show commands.'                                                                      >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>'                        >> .vimrc && \
echo '" Find symbol of current document.'                                                    >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>'                         >> .vimrc && \
echo '" Search workspace symbols.'                                                           >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>'                      >> .vimrc && \
echo '" Do default action for next item.'                                                    >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>'                                 >> .vimrc && \
echo '" Do default action for previous item.'                                                >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>'                                 >> .vimrc && \
echo '" Resume latest coc list.'                                                             >> .vimrc && \
echo 'nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>'                           >> .vimrc && \
echo 'endif'                                                                                 >> .vimrc && \
echo 'unbind C-b'                          >> .tmux.conf && \
echo 'set-option -g prefix C-a'            >> .tmux.conf && \
echo 'bind-key C-a send-prefix'            >> .tmux.conf && \
echo 'set-option -g default-command bash'  >> .tmux.conf && \
echo 'set-option -g status-position top'   >> .tmux.conf && \
echo 'set -g status-interval 1'            >> .tmux.conf && \
echo 'set -g status-bg colour22'           >> .tmux.conf && \
echo 'set -g status-fg white'              >> .tmux.conf && \
echo 'set-option -s escape-time 0'         >> .tmux.conf && \
mkdir -p .config/nvim && \
echo '" For adding existing .vimrc to neovim'            >> .config/nvim/init.vim && \
echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' >> .config/nvim/init.vim && \
echo 'let &packpath = &runtimepath'                      >> .config/nvim/init.vim && \
echo 'source ~/.vimrc'                                   >> .config/nvim/init.vim && \
nvim +'PlugInstall --sync' +qa



# -fix alt-c
# /Add vim plugins
# -Try neovim
# -Write the above as a shell script, then write another script to conver it to a dockerfile
# *Configure clangd : https://clangd.llvm.org/installation.html#project-setup
# -Escape key not working in vim in tmux


# vim command reference
#
# gg=G         # fix formatting
# :TlistOpen   # Open taglist window

# RUN cd /home/mike && \
# git clone https://github.com/llvm/llvm-project && \
# mkdir llvm-project/build && \
# cd llvm-project/build && \
# cmake /home/make/llvm-project/llvm/ -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
