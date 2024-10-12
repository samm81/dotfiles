if isinstalled 'tmux'; then
  alias 'org-pane'='tmux-link-org-pane'
  alias tmuxd='tmux new -s ${PWD##*/}'
  alias tmuxld='tmux new -L ${PWD##*/} -s ${PWD##*/}'
  alias tmuxldd='tmux new -L ${$(cd ..;pwd)##*/} -s ${PWD##*/}'

  vim_desired_content_width=120
  export VIM_NUMBERWIDTH=4
  vim_total_width=$((vim_desired_content_width + VIM_NUMBERWIDTH))
  export TMUX_MAIN_PANE_WIDTH="$vim_total_width"
fi
