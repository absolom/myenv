# This is my dev environment

# Using alpine linux for base image
FROM alpine

# If you have a proxy, set these
# ENV http_proxy=...
# ENV https_proxy=...

ARG UNAME=mike
ARG GNAME=gamers
ARG UID=1000
ARG GID=1000

# Install packages and setup user
RUN apk update && \
apk add alpine-sdk sudo bash gcc g++ make cmake git tmux perl curl the_silver_searcher ctags nodejs && \
apk add npm build-base cmake automake autoconf libtool pkgconf coreutils curl unzip && \
apk add gettext-tiny-dev ripgrep fd python3 && \
apk add fzf fzf-bash-completion fzf-vim py3-pip shadow && \
apk add cscope --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

## apk add clang clang-static clang-dev llvm-dev llvm-static clang-extra-tools
## addgroup -S gamers && adduser -S mike -G gamers -s /usr/bash && \
## adduser mike wheel && \
## sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

# Build and install clangd
RUN cd /root && \
git clone https://github.com/llvm/llvm-project && \
mkdir llvm-project/build && \
cd llvm-project/build && \
cmake /home/mike/llvm-project/llvm/ -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" && \
cmake --build . && \
sudo cmake --build . --target install && \
cd ../.. && rm -rf llvm-project

# Build and install neovim
RUN cd /root && git clone https://github.com/neovim/neovim && cd neovim && make && sudo make install && cd .. && rm -rf neovim

# Create user
RUN groupadd -g $GID $GNAME && \
useradd -s /bin/bash -g $GID -u $UID $UNAME && \
adduser $UNAME wheel && \
sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

# Copy scripts/env
COPY deploy/ /home/mike

# Swap to new user
USER mike

# If you have a proxy, set these
# ENV http_proxy=...
# ENV https_proxy=...


# Clone some repos to test compiler and vim with and compile latest neovim
RUN sudo chown -R $UNAME:$GNAME /home/$UNAME && \
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
mkdir -p /home/$UNAME/.config/nvim && \
pip3 --trusted-host files.pythonhosted.org --trusted-host pypi.org install compiledb && \
sudo npm i -g pyright && \
nvim +'PlugInstall --sync' +qa && \
# --trusted-host args are probably not needed if not behind a firewall

# Clone some source to test the environment
RUN cd /home/mike && git clone https://github.com/libretro/libretro-super && \
cd libretro-super && ./libretro-fetch.sh retroarch && cd retroarch

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
