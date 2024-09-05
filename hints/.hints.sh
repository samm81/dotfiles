hint() {
  hint="$1"
  commnd="$2"
  # shellcheck disable=SC2139
  alias "${hint}=echo \$ ${commnd}; ${commnd}"
}

hint 'list-fonts' 'fc-list'

set_default_sink() {
  echo '$ pactl list short sinks'
  pactl list short sinks
  # shellcheck disable=SC2016
  echo '$ pactl set-default-sink '\''$SINK_NAME'\'
}
alias 'set-default-sink'='set_default_sink'

hint 'logs' 'svlogtail'

timezone() {
  echo '$ ln -sf /usr/share/zoneinfo/<timezone> /etc/localtime'
}

hint 'pdf' 'zathura'

# although this is slick, it breaks the auto completion :(
## rename `asdf` to `orig_asdf`
## `orig_` must come first because this is doing string concat
#eval "orig_$(declare -f asdf)"
#asdf-shim() {
#([ "$1" = "install" ] \
#  && [ "$2" = "nodejs" ] \
#  && ASDF_NODEJS_FORCE_COMPILE=1 orig_asdf "$@") \
#  || orig_asdf "$@"
#}
#alias 'asdf=asdf-shim'

alias 'git-local-ignore'="echo '.git/info/exclude'"

alias 'docker-clean'='docker system prune'

hint image swayimg

find-string-in-dir() {
  string="$1"
  shift
  rg "$string" \
    --sort 'path' \
    --files-with-matches -l \
    "$@"
}

swaymsg_orig="$(which swaymsg)"
swaymsg-shim() {
  cmd="$1"
  if [[ "$cmd" == "output" ]]; then
    echo "don't forget to surround with quotes:"
    echo "\`swaymsg 'ouput \"Some Company ASDF 4242\" command'"
  fi
  eval "$swaymsg_orig $@"
}
alias 'swaymsg=swaymsg-shim'

alias 'browser=w3m'

hint 'video' 'vlc'

grub-clean() {
  echo "sudo vkpurge list"
  echo "sudo vkpurge rm X.*"
}

xbps-update() {
  # TODO check if root
  sudo xbps-install -Su xbps
  sudo xbps-install -Su
  sudo xlocate -S
  sudo vkpurge list
  echo 'sudo vkpurge rm X.*'
}

portscan() {
  set +x
  nmap -sP 192.168.1.0/24 \
    | grep 'Nmap scan report for' \
    | awk '{print $5}' \
    | xargs -I {} nmap -sV {}
  set -x
}

root-clean() {
  sudo xbps-remove -O -o
}

before-reboot() {
  root-clean
  xbps-update
  grub-clean
}

asdf-update-nodejs-lts() {
  set +x
  asdf nodejs update-nodebuild
  ASDF_NODEJS_FORCE_COMPILE=1 \
    asdf install nodejs $(asdf nodejs resolve lts --latest-available)
  set -x
}
