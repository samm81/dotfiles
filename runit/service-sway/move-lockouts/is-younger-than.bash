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

[[ "${TRACE:-0}" == '1' ]] && set -o xtrace

usage() {
  local filename
  filename="$(basename "$0")"
  echo "usage: ./${filename} <ile> <maxage>"
  echo '  returns is `file` is younger than `maxage`'
  exit
}

[[ "${1:-}" =~ ^-*h(e(l(p)?)?)?$ ]] && usage

main() {
  file="${1:?missing required param \`file\`}"
  maxage="${2:?missing required param \`maxage\`}"

  # If the file doesn't exist, treat it as "too old"
  if [[ ! -e "$file" ]]; then
    exit 1
  fi

  # seconds since epoch
  file_mtime=$(stat -c %Y "$file")
  now=$(date +%s)

  if (( now - file_mtime < maxage )); then
    exit 0
  else
    exit 1
  fi
}

main "$@"

exit 0
