source /usr/share/fzf/key-bindings.bash

colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}

alias ls='ls --color'
alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias vim='nvim'

__fzf_branch__() {
  local cmd="git for-each-ref --shell --format='%(refname)' refs/ | tr -d \\' | sed 's|^refs/heads/\\(.*\\)|\1|' | sed 's|^refs/remotes/\\(.*\\)|\1|'"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --binb=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
    printf '%q' "$item"
  done
}

__fzf_branch_strip__() {
  local cmd="git for-each-ref --shell --format='%(refname)' | tr -d \\' | sed 's|^refs/heads/\\(.*\\)|\1|' | sed 's|^refs/remotes/origin/\\(.*\\)|\1|'"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --binb=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
    printf '%q' "$item"
  done
}

__fzf_branch_widget__() {
  local selected="$(__fzf_branch__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

__fzf_branch_strip_widget__() {
  local selected="$(__fzf_branch__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# CTRL-b - Paste the selected file git branch into the command line (strip origin/)
bind -m emacs-standard -x '"\C-b": __fzf_branch_strip_widget__'
bind -m vi-command -x '"\C-b": __fzf_branch_strip_widget__'
bind -m vi-insert -x '"\C-b: __fzf_branch_strip_widget__'

# CTRL-n - Paste the selected file git branch into the command line (no strip origin/)
bind -m emacs-standard -x '"\C-n": __fzf_branch_widget__'
bind -m vi-command -x '"\C-n": __fzf_branch_widget__'
bind -m vi-insert -x '"\C-n: __fzf_branch_widget__'

export PS1="\w$ "

clear

if [ ! -f ".SETUP_DONE" ]; then
  ColorMsg="\e[1;32m"
  ColorNone="\e[0m"
  echo -e "${ColorMsg}Final setup (to turn off this message 'touch .SETUP_DONE'):${ColorNone}"
  echo -e "  Run ':CocInstall coc-clangd' inside vim."
fi
