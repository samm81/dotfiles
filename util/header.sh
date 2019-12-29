#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
	# Bash 4.4, Zsh
	set -euo pipefail
else
	# Bash 4.3 and older chokes on empty arrays with set -u.
	set -eo pipefail
fi
shopt -s nullglob globstar

function check_installed() {
    if ! test "$(command -v ${1})"; then
        echo "${1} is not installed, please install ${1} and then retry"
        exit 1
    fi
}

check_installed "git"
# go to root of git directory
cd "$(git rev-parse --show-toplevel)"
