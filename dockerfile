# This is my dev environment

# Using alpine linux for base image
FROM alpine

RUN sed -i 's/https/http/' /etc/apk/repositories

# If you have a proxy, set these
# ENV http_proxy=...
# ENV https_proxy=...

ARG UNAME=mike
ARG GNAME=gamers
ARG UID=1000
ARG GID=1000

# Install packages and setup user
RUN apk update && \
apk add alpine-sdk sudo bash gcc g++ make cmake git tmux perl curl vim the_silver_searcher ctags clang && \
apk add clang-static clang-dev llvm-dev llvm-static clang-extra-tools nodejs npm build-base cmake automake && \
apk add autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev ripgrep fd python3 fzf fzf-bash-completion && \
apk add fzf-vim python3 shadow py3-pip openssh && \
apk add cscope --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Build clangd (long build, 8+ hours)
RUN cd /root && \
git clone https://github.com/llvm/llvm-project && \
mkdir llvm-project/build && \
cd llvm-project/build && \
cmake /root/llvm-project/llvm/ -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" && \
cmake --build . && \
cmake --build . --target install

# Build neovim
RUN cd /root && \
git clone https://github.com/neovim/neovim && cd neovim && make && make install

# Create user
RUN groupadd -g $GID $GNAME && \
useradd -s /bin/bash -g $GID -u $UID $UNAME && \
adduser $UNAME wheel && \
sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers

# Copy files over (precloned repos, config files, etc.)
RUN mkdir -p /home/$UNAME && chown $UNAME:$GNAME /home/$UNAME
COPY container/ /home/$UNAME

# Switch to new user
USER $UNAME

# If you have a proxy, set these again for user
# ENV http_proxy=...
# ENV https_proxy=...

# Clone some repos to test compiler and vim with and compile latest neovim
RUN sudo chown -R $UNAME:$GNAME /home/$UNAME && \
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
mkdir -p /home/$UNAME/.config/nvim && \
nvim +'PlugInstall --sync' +qa && \
pip3 --trusted-host files.pythonhosted.org --trusted-host pypi.org install compiledb && \
sudo npm i -g pyright
# --trusted-host args are probably not needed if not behind a firewall

# Clone some source to test the environment
RUN cd /home/mike && git clone https://github.com/libretro/libretro-super && \
cd libretro-super && ./libretro-fetch.sh retroarch && cd retroarch
