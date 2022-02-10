source /usr/share/fzf/key-bindings.bash

colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}

alias ls='ls --color'
alias gs='git status'
alias gb='git branch'
alias vim='nvim'

__fzf_branch__() {
  local cmd="git for-each-ref --shell --format='%(refname)' refs/ | tr -d \\' | sed 's|^refs/heads/\\(.*\\)|\1|' | sed 's|^refs/remotes/\\(.*\\)|\1|'"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --binb=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
    printf '%q' "$item"
  done
}

__fzf_branch_widget__() {
  local selected="$(__fzf_branch__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# CTRL-B - Paste the selected file git branch into the command line
bind -m emacs-standard -x '"\C-b": __fzf_branch_widget__'
bind -m vi-command -x '"\C-b": __fzf_branch_widget__'
bind -m vi-insert -x '"\C-b: __fzf_branch_widget__'

cd $HOME
