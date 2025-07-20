#!/usr/bin/env bash
# unofficial strict mode
# note bash<=4.3 chokes on empty arrays with set -o nounset
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# https://sharats.me/posts/shell-script-best-practices/
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
shopt -s nullglob globstar

[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

usage() {
  local filename
  filename="$(basename "$0")"
  echo "Usage: ./${filename}"
  echo '  locks screen only if it is on'
  exit
}

[[ "${1:-}" =~ ^-*h(elp)?$ ]] && usage

main() {
  [[ $(swaymsg -t get_outputs | jq 'map(.active) | any') == 'true' ]] \
    && swaylock --color '000022' --ignore-empty-password
}

main "$@"

exit 0
