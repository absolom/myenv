# This is my dev environment

# Using alpine linux for base image
FROM alpine

# Install packages and setup user
RUN apk update && \
apk add sudo bash gcc g++ make cmake git tmux perl curl vim the_silver_searcher ctags clang clang-extra-tools nodejs npm build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev && \
apk add cscope --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
addgroup -S gamers && adduser -S mike -G gamers -s /usr/bash && \
adduser mike wheel && \
sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

# Swap to new user
USER mike

# Clone some repos to test compiler and vim with
RUN cd /home/mike && git clone https://github.com/libretro/libretro-super && \
cd libretro-super && ./libretro-fetch.sh retroarch && cd retroarch && cscope -Rb && cd /home/mike && \
git clone https://github.com/neovim/neovim && cd neovim && make && sudo make install

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
