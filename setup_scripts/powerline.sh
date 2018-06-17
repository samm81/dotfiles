#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
	# Bash 4.4, Zsh
	set -euo pipefail
else
	# Bash 4.3 and older chokes on empty arrays with set -u.
	set -eo pipefail
fi
shopt -s nullglob globstar

# go to root of git directory
cd "$(git rev-parse --show-toplevel)"

# checks
if ! test "$(command -v pip3)"; then
	echo "pip3 is not installed, please install pip3 and then retry"
	exit 1
fi
if ! test "$(command -v fc-cache)"; then
	echo "fontconfig is not installed, please install fontconfig and then retry"
	exit 1
fi
if ! test "$(command -v stow)"; then
	echo "stow is not installed, please install stow and then retry"
	exit 1
fi

pip3 install --user powerline-status
stow powerline
fc-cache -vf ~/.fonts/
