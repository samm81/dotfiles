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

record() {
  trap "pkill -INT wf-recorder" INT
  wf-recorder --force-yuv -g "$(slurp)"
}

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

hint 'ngrok' 'ssh -N -R 8013:localhost:8013 mni.ac'
