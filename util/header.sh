#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

# use colors, but only if connected to a terminal that supports them
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
[ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]
has_colors=$?
RED="$( (( has_colors == 0 )) && tput setaf 1 || echo '' )"
GREEN="$( (( has_colors == 0 )) && tput setaf 2 || echo '' )"
YELLOW="$( (( has_colors == 0 )) && tput setaf 3 || echo '' )"
BLUE="$( (( has_colors == 0 )) && tput setaf 4 || echo '' )"
BOLD="$( (( has_colors == 0 )) && tput bold || echo '' )"
NORMAL="$( (( has_colors == 0 )) && tput sgr0 || echo '' )"
err () {
  [[ -n ${1:-} ]] && echo "${RED}${1}${NORMAL}"
}

function check_installed() {
  if ! test "$(command -v ${1})"; then
    err "${1} is not installed, please install ${1} and then retry"
    exit 1
  fi
}

check_installed "git"
# go to root of git directory
cd "$(git rev-parse --show-toplevel)"
