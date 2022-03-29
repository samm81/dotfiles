export ZSH="${HOME}/.oh-my-zsh"
export ZSHRC="${HOME}/.zshrc"

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
plugins=(git asdf colored-man-pages)

ASDF="$HOME/.asdf"
[ -d "$ASDF" ] && plugins+=('asdf') && fpath+=("$ASDF/completions")

# from https://github.com/zsh-users
#plugins+=(zsh-auto-notify) # non-built in
plugins+=(zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

# make zsh-autosuggestions play nice with st
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=11"

source $ZSH/oh-my-zsh.sh

# for zsh-completions
autoload -Uz compinit && compinit
# only autocorrect commands
unsetopt correct_all
setopt correct

# zsh-autosuggest
bindkey '^\' autosuggest-execute

# zsh-auto-notify
#AUTO_NOTIFY_IGNORE+=("git", "tmux", "docker run")
#export AUTO_NOTIFY_EXPIRE_TIME=4000

# theme fix
battery_time_remaining() {
  echo -n ""
}
