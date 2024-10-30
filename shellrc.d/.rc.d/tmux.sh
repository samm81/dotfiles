if isinstalled 'tmux'; then
  alias 'org-pane'='tmux-link-org-pane'
  alias tmuxd='tmux new -s ${PWD##*/}'
  alias tmuxld='tmux new -L ${PWD##*/} -s ${PWD##*/}'
  alias tmuxldd='tmux new -L ${$(cd ..;pwd)##*/} -s ${PWD##*/}'

  # 120 characters plus the visible return character
  vim_desired_content_width=121
  export VIM_NUMBER_GUTTER_WIDTH=4
  vim_total_width=$((vim_desired_content_width + VIM_NUMBER_GUTTER_WIDTH))
  export TMUX_MAIN_PANE_WIDTH="$vim_total_width"
fi
