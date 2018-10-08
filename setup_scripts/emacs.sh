#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
	# Bash 4.4, Zsh
	set -euo pipefail
else
	# Bash 4.3 and older chokes on empty arrays with set -u.
	set -eo pipefail
fi
shopt -s nullglob globstar

if ! test "$(command -v stow)"; then
	echo "stow is not installed, please install stow and then retry"
	exit 1
fi

# go to root of git directory
cd "$(git rev-parse --show-toplevel)"
stow emacs
