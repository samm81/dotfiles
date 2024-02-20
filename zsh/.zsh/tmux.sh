alias 'org-pane'='tmux-link-org-pane'

vim_content_width=120
export VIM_NUMBERWIDTH=4
vim_total_width=$((vim_content_width + VIM_NUMBERWIDTH))
export TMUX_MAIN_PANE_WIDTH="$vim_total_width"
