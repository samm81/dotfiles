export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="random"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages)

if isinstalled 'pdm'; then
  # `ZSH_CUSTOM` is set by `oh-my-zsh` it seems, so cheat a little here
  zsh_custom="${ZSH}/custom"
  ZSH_CUSTOM_PLUGINS_PDM_DIR="${zsh_custom}/plugins/pdm"
  plugins+=('pdm')
  # if the `pdm` plugin dir is missing, it will warn, but this will tell the user exactly what to do
  [ ! -d "$ZSH_CUSTOM_PLUGINS_PDM_DIR" ] &&
    echo "${ZSH_CUSTOM_PLUGINS_PDM_DIR} missing, probably need to run \`pdm completion zsh > " \
      "\$ZSH_CUSTOM/plugins/pdm/_pdm\`"
fi

# from https://github.com/zsh-users
#plugins+=(zsh-auto-notify) # non-built in
plugins+=(zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# for zsh-completions
autoload -Uz compinit && compinit
# only autocorrect commands
unsetopt correct_all
setopt correct

# zsh-autosuggest
# shellcheck disable=SC1003
bindkey '^\' autosuggest-execute
# make the suggestions more visible
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=11"

# zsh-auto-notify
#AUTO_NOTIFY_IGNORE+=("git", "tmux", "docker run")
#export AUTO_NOTIFY_EXPIRE_TIME=4000

# theme fixes
battery_pct_prompt() {
  echo ""
}
zsh_path() {
  echo ""
}
rbenv() {
  echo ""
}
jenv_prompt_info() {
  echo ""
}
