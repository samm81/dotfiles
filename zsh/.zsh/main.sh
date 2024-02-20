# User configuration

export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# long history
export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups

# preferred editor
check_installed 'vim' && export EDITOR='vim'

# for tmuxp
export DISABLE_AUTO_TITLE='true'

# iex
check_installed 'iex' && export ERL_AFLAGS="-kernel shell_history enabled"

# hledger
check_installed 'hledger' \
  && LEDGER_FILE="${HOME}/scratch/$(date +%Y).ledger" \
  && export LEDGER_FILE

# python
check_installed 'python' && export PYTHONDONTWRITEBYTECODE="plsno"

# pipenv
check_installed 'pipenv' && export PIPENV_VENV_IN_PROJECT=1
# (really slow)
#check_installed "pipenv" && eval "$(pipenv --completion)"

# nix
NIX="${HOME}/.nix-profile/etc/profile.d/nix.sh"
[ -e "${NIX}" ] && source "${NIX}"

check_installed "direnv" && eval "$(direnv hook zsh)" && direnv() { asdf exec direnv "$@"; }

check_installed "keychain" && eval "$(keychain --eval id_ed25519)"

# heroku autocomplete setup
check_installed 'heroku' && \
  HEROKU_AC_ZSH_SETUP_PATH="$HOME/.cache/heroku/autocomplete/zsh_setup" \
  && [ -f "$HEROKU_AC_ZSH_SETUP_PATH" ] \
  && source "$HEROKU_AC_ZSH_SETUP_PATH"

# bitwarden
check_installed 'bw' && eval "$(bw completion --shell zsh); compdef _bw bw;"

# fzf
# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
if [ -f ~/.fzf.zsh ] ; then
  source ~/.fzf.zsh
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }
  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

drop_in() {
  ORIGINAL="${1:?must pass original command name to drop_in}"
  NEW="${2:?must pass new command name to drop_in}"
  HINT=${3:-}
  [ -n "$HINT" ] && HINT=">&2 echo ${HINT};"
  check_installed "$NEW" && alias "$ORIGINAL"="${HINT}${NEW}"
}

drop_in 'pip' 'pip3'
drop_in 'diff' 'delta'
drop_in 'ls' 'exa' \
  && alias ll='exa --long --header --git' \
  && alias la='exa --long --header --git --all'
drop_in 'grep' 'rg' && export FZF_DEFAULT_COMMAND='rg --files'
drop_in 'find' 'fd' "[orig] find -iname '*PATTERN*'"
check_installed 'bat' && alias cat='bat'
check_installed 'xclip' && alias clip='xclip -selection c'
check_installed 'tmux' && alias tmuxd='tmux new -s ${PWD##*/}'
check_installed 'feh' && alias feh='feh -. --auto-rotate'
alias less='less -N'

check_installed cs && eval "$(cs --completions zsh)"

# TODO this hangs on startup if not connected to internet
#check_installed kubectl && source <(kubectl completion zsh)

check_installed pipx && eval "$(register-python-argcomplete pipx)"

apropos '' 2> /dev/null | shuf -n 1 && echo ''
