source /usr/share/fzf/key-bindings.bash
colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}
cd $HOME