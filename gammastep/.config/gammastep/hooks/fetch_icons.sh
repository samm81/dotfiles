#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar
#set -o xtrace # set debugging flag, aka set -x

get() {
  url="$1"
  wget --quiet --no-clobber "$url"
}

get 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/0078392516a3c27e5549c5643fd8237a9063b344/svgs/regular/moon.svg'
get 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/0078392516a3c27e5549c5643fd8237a9063b344/svgs/solid/rotate.svg'
get 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/0078392516a3c27e5549c5643fd8237a9063b344/svgs/regular/sun.svg'
