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
if ! test "$(command -v stow)"; then
	echo "stow is not installed, please install stow and then retry"
	exit 1
fi
if ! test "$(command -v curl)"; then
	echo "curl is not installed, please install stow and then retry"
	exit 1
fi

# go to root of git directory
cd "$(git rev-parse --show-toplevel)"

if ! test -f vim/.vim/autoload/plug.vim; then
	curl -fLo vim/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
if test -f "$HOME/.vimrc"; then
	echo "existing .vimrc file detected, moving it to ~/._vimrc"
	mv "$HOME/.vimrc" "$HOME/._vimrc"
fi
stow vim
vim -c "PlugInstall" -c "visual" -c "qa"
