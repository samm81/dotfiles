hint() {
  hint="$1"
  commnd="$2"
  # shellcheck disable=SC2139
  alias "${hint}=echo \$ ${commnd}; ${commnd}"
}

hint 'list-fonts' 'fc-list'

set_default_sink () {
  echo '$ pactl list short sinks'
  pactl list short sinks
  # shellcheck disable=SC2016
  echo '$ pactl set-default-sink '\''$SINK_NAME'\'
}
alias 'set-default-sink'='set_default_sink'

git_clean() {
  echo '$ git fetch --prune'
  git fetch --prune
  echo '$ git branch --merged | grep -E -v "(^\*|master|main)" | xargs git branch -d'
  git branch --merged | grep -v "(^\*|master|main)" | xargs git branch -d
  echo '$ git branch --no-merged'
  git branch --no-merged | cat
  # shellcheck disable=SC2016
  echo '$ git branch -D '\''$BRANCH_NAME'\'
}
alias 'git-clean'='git_clean'

hint 'logs' 'svlogtail'

timezone() {
  echo '$ ln -sf /usr/share/zoneinfo/<timezone> /etc/localtime'
}

alias 'pdf' 'zathura'

asdf_=$(which asdf)
asdf-shim() {
  [ "$1" = "install" ] && [ "$2" = "nodejs" ] && ASDF_NODEJS_FORCE_COMPILE=1 asdf_ "$@"
}
alias 'asdf=asdf-shim'

alias gitlocalignore="echo '.git/info/exclude'"

alias docker-clean='docker system prune'
