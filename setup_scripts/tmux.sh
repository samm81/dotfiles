#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
	# Bash 4.4, Zsh
	set -euo pipefail
else
	# Bash 4.3 and older chokes on empty arrays with set -u.
	set -eo pipefail
fi
shopt -s nullglob globstar

# checks
if ! test "$(tmux -v)"; then
	echo "tmux is not installed, please install tmux and then retry"
	exit 1
fi
if ! test "$(git -v)"; then
	echo "git is not installed, please install git and then retry"
	exit 1
fi

# go to root of git directory
cd "$(git rev-parse --show-toplevel)"

if test -f "$HOME/.tmux.conf"; then
	echo "existing .tmux.conf file detected, moving it to ~/._tmux.conf"
	mv "$HOME/.tmux.conf" "$HOME/._tmux.conf"
fi
stow tmux

# tmux pacakge manager
git clone https://github.com/tmux-plugins/tpm tmux/.tmux/plugins/tpm

# tmuxp...?
