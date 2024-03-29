sourc() {
  ZSH_FILE="$1"
  [ -f "$ZSH_FILE" ] && source "$ZSH_FILE"
}

ZSH_DIR="$HOME/.zsh"

sourc "$ZSH_DIR/profiling.sh"
sourc "$ZSH_DIR/theme_fixes.sh"
sourc "$ZSH_DIR/oh-my-zsh.sh"
sourc "$ZSH_DIR/check_installed.sh"
sourc "$ZSH_DIR/ssh-agent.sh"
sourc "$ZSH_DIR/main.sh"
sourc "$ZSH_DIR/256color.sh"
sourc "$ZSH_DIR/sway.sh"
sourc "$ZSH_DIR/flatpak.sh"
sourc "$ZSH_DIR/direnv.sh"
sourc "$ZSH_DIR/tmux.sh"
sourc "$ZSH_DIR/zinit.sh"
sourc "$ZSH_DIR/mcfly.sh"
sourc "$ZSH_DIR/asdf.zsh"
sourc "$ZSH_DIR/pg.sh"

sourc "$ZSH_DIR/$(hostname).sh"

sourc "$HOME/.hints.sh"
