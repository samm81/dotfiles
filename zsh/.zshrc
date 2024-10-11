ZSH_DIR="$HOME/.zsh"

source "$ZSH_DIR/profiling.sh"

sourc() {
  local file="$1"
  [ -f "$file" ] && source "$file"
}

sourcz() {
  local file="$1"
  sourc "${ZSH_DIR}/${file}.sh"
  sourc "${ZSH_DIR}/${file}.bash"
  sourc "${ZSH_DIR}/${file}.zsh"
}

sourcz 'check_installed'

sourczif() {
  local program="$1"
  check_installed "$program" && sourcz "$program"
}

sourcz 'zsh'
sourcz 'theme_fixes'
sourcz 'oh-my-zsh'
sourcz 'zinit'

sourcz 'main'

sourcz 'ssh-agent'
sourcz '256color'
sourcz 'flatpak'
sourcz 'direnv'
sourcz 'pg'
sourcz 'sudo'
sourcz 'fly'

sourczif 'tmux'
sourczif 'sway'
sourczif 'mcfly'
sourczif 'asdf'
sourczif 'foot'
sourczif 'foot'
sourczif 'nvim'

sourcz "$(hostname).sh"

sourc "$HOME/.hints.sh"
