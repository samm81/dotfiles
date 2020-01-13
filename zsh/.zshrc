# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="random"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

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
plugins=(git fasd lwd pip python tmux ruby colored-man-pages)
#plugins+=(k) # non-built in
# from https://github.com/zsh-users
plugins+=(zsh-autosuggestions zsh-completions zsh-syntax-highlighting)
# make zsh-autosuggestions play nice with st
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=11"
# for zsh-completions
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.gem/ruby/2.5.0/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.npm-packages/bin:$PATH
export MANPATH=/usr/local/man:$MANPATH
export MANPATH=$HOME/.npm-packages/share/man:$MANPATH

# preferred editor
export EDITOR='vim'

# ssh-agent
# set environment variables if user's agent already exists
[ -z "$SSH_AUTH_SOCK" ] && SSH_AUTH_SOCK=$(ls -l /tmp/ssh-*/agent.* 2> /dev/null | grep $(whoami) | awk '{print $9}')
[ -z "$SSH_AGENT_PID" -a -z `echo $SSH_AUTH_SOCK | cut -d. -f2` ] && SSH_AGENT_PID=$((`echo $SSH_AUTH_SOCK | cut -d. -f2` + 1))
[ -n "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK
[ -n "$SSH_AGENT_PID" ] && export SSH_AGENT_PID

# start agent if necessary
if [ -z $SSH_AGENT_PID ] && [ -z $SSH_TTY ]; then  # if no agent & not in ssh
  eval `ssh-agent -s` > /dev/null
fi

# setup addition of keys when needed
if [ -z "$SSH_TTY" ] ; then                     # if not using ssh
  ssh-add -l > /dev/null                        # check for keys
  if [ $? -ne 0 ] ; then
    alias ssh='ssh-add -l > /dev/null || ssh-add && unalias ssh ; ssh'
    if [ -f "/usr/lib/ssh/x11-ssh-askpass" ] ; then
      SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass" ; export SSH_ASKPASS
    fi
  fi
fi

# long history
export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

function check_installed() {
    test "$(command -v ${1})"
}

check_installed "xclip" && alias clip="xclip -selection c"
check_installed "python3" && alias python="python3"
check_installed "pip3" && alias pip="pip3"
check_installed "bat" && alias cat="bat"
check_installed "exa" && \
  alias ls="exa"
  alias ll="exa --long --header --git" && \
  alias la="exa --long --header --git --all"
check_installed "tmux" && alias tmuxd="tmux new -s \${PWD##*/}"
check_installed "pcmanfm" && alias files="pcmanfm"
check_installed "brave-browser-dev" && alias bbd="brave-browser-dev"
alias lkjh="source ~/.zshrc" # give me a new theme

# ctrl-r search backwards
bindkey '^R' history-incremental-search-backward

# enable tmux continuum
export TMUX_CONTINUUM='true'

# for tmuxp
export DISABLE_AUTO_TITLE='true'

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
  [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"

# iex
export ERL_AFLAGS="-kernel shell_history enabled"

export PYTHONDONTWRITEBYTECODE="plsno"

# zsh-autosuggest
bindkey '^\' autosuggest-execute

echo "xargs find jq awk tldr \$! neofetch"
echo "cht.sh ss-local tsocks shellcheck"
