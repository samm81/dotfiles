hint() {
  hint="$1"
  commnd="$2"
  # shellcheck disable=SC2139
  alias "${hint}=echo \$ ${commnd}; ${commnd}"
}

hint 'list-fonts' 'fc-list'

set-default-sink() {
  echo '$ pactl list short sinks'
  pactl list short sinks
  # shellcheck disable=SC2016
  echo '$ pactl set-default-sink '\''$SINK_NAME'\'
}

hint 'logs' 'svlogtail'

timezone() {
  echo '$ ln -sf /usr/share/zoneinfo/<timezone> /etc/localtime'
}

hint 'pdf' 'zathura'

alias 'git-local-ignore'="echo '.git/info/exclude'"

alias 'docker-clean'='docker system prune'

hint 'image' 'swayimg'

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
    echo "\`swaymsg 'ouput \"Some Company XYZZ 4242\" command'"
  fi
  eval "$swaymsg_orig $*"
}
alias 'swaymsg'='swaymsg-shim'

alias 'browser'='w3m'

hint 'video' 'mpv'

grub-clean() {
  sudo vkpurge list
  echo "sudo vkpurge rm X.*"
}

xbps-update() {
  # TODO check if root
  sudo xbps-install -Su xbps
  sudo xbps-install -Su
  sudo xlocate -S
}

portscan() {
  set +x
  nmap -sP 192.168.1.0/24 |
    grep 'Nmap scan report for' |
    awk '{print $5}' |
    xargs -I {} nmap -sV {}
  set -x
}

root-clean() {
  sudo xbps-remove -O -o
}

update() {
  set -x
  xbps-update
  pipx upgrade-all
  npm -g update
  set +x
  echo 'TODO `~/.docker/cli-plugins/docker-compose`'
  echo 'TODO `~/bin/cljfmt`'
  echo 'TODO `~/bin/mcfly`'
  echo 'TODO `'"${ZSH_CUSTOM}"'`'
  for f in ~/bin/*.AppImage; do
    echo "TODO $f"
  done
  for d in ~/src/*; do
    echo "TODO $d"
  done
}

before-reboot() {
  root-clean
  update
  grub-clean
}
