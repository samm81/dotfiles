#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

ICON_DIR="$HOME/.config/gammastep/hooks/"

event="$1"
# 'night' 'daytime' 'transition'
old_period="$2"
new_period="$3"

handle-period-changed() {
  from="$1"
  to="$2"
  case "$to" in
    'night') icon='moon.svg' ;;
    'daytime') icon='sun.svg' ;;
    'transition') icon='rotate.svg' ;;
  esac
  echo "${ICON_DIR}${icon}"
  exec notify-send \
    --icon="${ICON_DIR}${icon}" \
    --expire-time=5000 \
    'Gammastep' "Period changed to $to"
}

case "$event" in
  'period-changed')
    handle-period-changed "$old_period" "$new_period"
    ;;
esac
