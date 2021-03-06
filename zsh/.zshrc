# instrumentation for profiling
# https://esham.io/2018/02/zsh-profiling
#zmodload zsh/datetime
#setopt PROMPT_SUBST
#PS4='+$EPOCHREALTIME %N:%i> '
#
#logfile=$(mktemp zsh_profile.XXXXXXXX)
#echo "Logging to $logfile"
#exec 3>&2 2>$logfile
#
#setopt XTRACE

zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
export ZSHRC="${HOME}/.zshrc"

# fix some zsh themes
function battery_pct_prompt { echo "" }
function zsh_path { echo "" }
function rvm-prompt { echo "" }
function rbenv { echo "" }
function jenv_prompt_info { echo "" }

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
plugins=(git) # pip python tmux ruby colored-man-pages)
plugins+=(zsh-auto-notify) # non-built in
# from https://github.com/zsh-users
plugins+=(zsh-autosuggestions zsh-completions zsh-syntax-highlighting)
# make zsh-autosuggestions play nice with st
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=11"

source $ZSH/oh-my-zsh.sh

# for zsh-completions
#autoload -Uz compinit && compinit
# only autocorrect commands
unsetopt correct_all
setopt correct

# User configuration

export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.gem/ruby/2.5.0/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/scripts:$PATH
export PATH=$HOME/.npm-packages/bin:$PATH
export MANPATH=/usr/local/man:$MANPATH
export MANPATH=$HOME/.npm-packages/share/man:$MANPATH

# preferred editor
export EDITOR='vim'

function check_installed() {
    test "$(command -v ${1})"
}

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
if check_installed "ssh-add"; then
  if [ -z "$SSH_TTY" ] ; then                     # if not using ssh
    ssh-add -l > /dev/null                        # check for keys
    if [ $? -ne 0 ] ; then
      alias ssh='ssh-add -l > /dev/null || ssh-add && unalias ssh ; ssh'
      if [ -f "/usr/lib/ssh/x11-ssh-askpass" ] ; then
        SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass" ; export SSH_ASKPASS
      fi
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

check_installed "xclip" && alias clip="xclip -selection c"
check_installed "python3" && alias python="python3"
check_installed "pip3" && alias pip="pip3"
check_installed "bat" && alias cat="bat"
check_installed "exa" && \
  alias ls="exa" && \
  alias ll="exa --long --header --git" && \
  alias la="exa --long --header --git --all"
check_installed "tmux" && alias tmuxd="tmux new -s \${PWD##*/}"
check_installed "pcmanfm" && alias files="pcmanfm"
check_installed "brave-browser-dev" && alias bbd="brave-browser-dev"
check_installed "rg" && alias grep="rg" \
    && export FZF_DEFAULT_COMMAND="rg --files"
alias less="less -N"
alias lkjh="exec zsh" # give me a new theme
alias feh="feh -. --auto-rotate"

# enable tmux continuum
export TMUX_CONTINUUM='true'

# for tmuxp
export DISABLE_AUTO_TITLE='true'

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "${PS1}" ] && \
  [ -s "${BASE16_SHELL}/profile_helper.sh" ] && \
    eval "$("${BASE16_SHELL}/profile_helper.sh")"

# iex
export ERL_AFLAGS="-kernel shell_history enabled"

# hledger
export LEDGER_FILE="${HOME}/scratch/$(date +%Y).ledger"

# python
export PYTHONDONTWRITEBYTECODE="plsno"

# pipenv
export PIPENV_VENV_IN_PROJECT=1
# (really slow)
#check_installed "pipenv" && eval "$(pipenv --completion)"

# zsh-autosuggest
bindkey '^\' autosuggest-execute

# asdf
ASDF="${HOME}/.asdf"
[[ -d ${ASDF} ]] && source "${ASDF}/asdf.sh"
#[[ -d ${ASDF} ]] && source "${ASDF}/completions/asdf.bash"

# nix
NIX="${HOME}/.nix-profile/etc/profile.d/nix.sh"
[[ -e "${NIX}" ]] && source "${NIX}"

# zsh-auto-ignore
AUTO_NOTIFY_IGNORE+=("git", "tmux", "docker run")
export AUTO_NOTIFY_EXPIRE_TIME=4000

alias ze="${EDITOR} ${ZSHRC}"

echo 'xargs find jq awk tldr !$ neofetch'
echo "cht.sh shellcheck style diction C-x C-e"

#unsetopt XTRACE
#exec 2>&3 3>&-

# https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html
# https://github.com/zdharma/zinit#calling-compinit-without-turbo-mode
# https://www.google.com/search?hl=en&q=zsh%20init%20compdump
# https://github.com/zsh-users/zsh-completions

alias fctix="${EDITOR} /home/maynard/.config/fcitx/data/QuickPhrase.mb"

alias gif="echo 'peek'"
