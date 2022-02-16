sourc() {
	ZSH_FILE="$1"
	[ -f "$ZSH_FILE" ] && source "$ZSH_FILE"
}

#sourc '.zsh/profiling.sh'
sourc '.zsh/theme_fixes.sh'
sourc '.zsh/oh-my-zsh.sh'
sourc '.zsh/check_installed.sh'
sourc '.zsh/ssh-agent.sh'
sourc '.zsh/main.sh'
sourc '.zsh/256color.sh'
sourc '.zsh/fo.sh'
sourc "$HOME/.hints.sh"
