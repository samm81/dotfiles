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
  echo "Usage: ./${filename}"
  echo '  fetches `themes/` dir from `foot` repo'
  exit
}

[[ "${1:-}" =~ ^-*h(elp)?$ ]] && usage

cd "$(dirname "$0")"

main() {
  git init --quiet
  git remote add origin 'https://codeberg.org/dnkl/foot.git'
  git sparse-checkout set --no-cone 'themes'
  git pull origin master --depth 1
}

main "$@"

exit 0
