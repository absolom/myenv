# This is my dev environment

# Using alpine linux for base image
FROM alpine

# Install packages and setup user
RUN apk update && \
apk add sudo bash gcc g++ make cmake git tmux perl curl vim the_silver_searcher ctags clang clang-extra-tools nodejs npm build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev ripgrep fd && \
apk add cscope --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
addgroup -S gamers && adduser -S mike -G gamers -s /usr/bash && \
adduser mike wheel && \
sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

# Swap to new user
USER mike

# latest clangd compilation, takes a long time so it gets its own layer
RUN cd /home/mike && \
git clone https://github.com/llvm/llvm-project && \
mkdir llvm-project/build && \
cd llvm-project/build && \
cmake /home/mike/llvm-project/llvm/ -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" && \
cmake --build . && \
cmake --build . --target install

# Clone some repos to test compiler and vim with and compile latest neovim
RUN cd /home/mike && git clone https://github.com/libretro/libretro-super && \
cd libretro-super && ./libretro-fetch.sh retroarch && cd retroarch && cscope -Rb && cd /home/mike && \
git clone https://github.com/neovim/neovim && cd neovim && make && sudo make install

sudo apk add python3

# Copy scripts/env
COPY --chown=mike:gamer deploy/ /home/mike

# Setup user specific stuff
RUN cd /home/mike && sudo apk add fzf fzf-bash-completion fzf-vim && \
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
vim +'PlugInstall --sync' +qa           && \
mkdir -p /home/mike/.config/coc         && \
sudo npm i -g pyright                   && \
mkdir -p .config/nvim                   && \
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
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

# References
# https://github.com/junegunn/fzf.vim
# https://github.com/neoclide/coc.nvim
# https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom
# https://docs.docker.com/engine/install/binaries/

# Need to go through for setup/tutorial
# https://github.com/nvim-treesitter/nvim-treesitter
# https://github.com/nvim-telescope/telescope.nvim#getting-started
# https://blog.inkdrop.app/how-to-set-up-neovim-0-5-modern-plugins-lsp-treesitter-etc-542c3d9c9887