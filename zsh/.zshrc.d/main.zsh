# prioritize user's `bin`s
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# long history
export HISTSIZE=50000
export SAVEHIST="$HISTSIZE"
setopt hist_ignore_all_dups

export EDITOR='vi'
isinstalled 'vim' && export EDITOR='vim'

isinstalled 'tmuxp' && export DISABLE_AUTO_TITLE='true'
isinstalled 'iex' && export ERL_AFLAGS='-kernel shell_history enabled'
isinstalled 'python' && export PYTHONDONTWRITEBYTECODE='plsno'
isinstalled 'direnv' && eval "$(direnv hook zsh)" && direnv() { asdf exec direnv "$@"; }
isinstalled 'keychain' && eval "$(keychain --eval id_ed25519)"
isinstalled 'cs' && eval "$(cs --completions zsh)"
isinstalled 'pipenv' && export PIPENV_VENV_IN_PROJECT=1
# (really slow)
#isinstalled "pipenv" && eval "$(pipenv --completion)"
isinstalled 'hledger' &&
  LEDGER_FILE="${HOME}/studio/scratch/$(date +%Y).ledger" &&
  export LEDGER_FILE
# bitwarden
isinstalled 'bw' && eval "$(bw completion --shell zsh); compdef _bw bw;"
# TODO this hangs on startup if not connected to internet
#isinstalled kubectl && source <(kubectl completion zsh)
isinstalled pipx && eval "$(register-python-argcomplete pipx)"

NIX="${HOME}/.nix-profile/etc/profile.d/nix.sh"
# shellcheck disable=SC1090
[[ -f "$NIX" ]] && [[ -r "$NIX" ]] && source "$NIX"

# heroku autocomplete
# shellcheck disable=SC1090
isinstalled 'heroku' &&
  HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH="$HOME/.cache/heroku/autocomplete/zsh_setup" &&
  [ -f "$HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH" ] &&
  source "$HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH"

# aliases

alias less='less --LINE-NUMBERS'

isinstalled 'bat' && alias cat='bat'
isinstalled 'xclip' && alias clip='xclip -selection c'
isinstalled 'feh' && alias feh='feh -. --auto-rotate'

drop_in() {
  ORIGINAL="${1:?must pass original command name to drop_in}"
  NEW="${2:?must pass new command name to drop_in}"
  HINT=${3:-}
  [ -n "$HINT" ] && HINT=">&2 echo ${HINT};"
  isinstalled "$NEW" && alias "$ORIGINAL"="${HINT}${NEW}"
}

drop_in 'pip' 'pip3'
drop_in 'diff' 'delta'
drop_in 'ls' 'exa' &&
  alias ll='exa --long --header --git' &&
  alias la='exa --long --header --git --all'
drop_in 'grep' 'rg' && export FZF_DEFAULT_COMMAND='rg --files'
drop_in 'find' 'fd' "[orig] find -iname '*PATTERN*'"
