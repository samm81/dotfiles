# Path to your oh-my-zsh installation.
export ZSH=/home/sam/src/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="random"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git common-aliases fasd lwd pip pylint python rand-quote tmux)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"

# preferred editor
export EDITOR='vim'

# heroku toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# go
export GOPATH="$HOME/go"
export PATH="$HOME/go/bin:$PATH"

# ruby
export PATH="$HOME/.gem/ruby/2.3.0/bin:$PATH"

# psueod v
alias v="f -e vim"

# k
source ~/src/k/k.sh
alias k="k -h"
alias ka="k -a"
alias kl="k -l"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# reminders
PROMPT="fasd k noti pylint $PROMPT"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias clip="xclip -selection c"
alias hn=pyhn
