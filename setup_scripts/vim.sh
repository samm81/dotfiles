#!/usr/bin/env bash
. util/header.sh

check_installed stow
check_installed curl

if [[ -f "${HOME}/.vimrc" ]]; then
	echo "existing .vimrc file detected, moving it to ~/._vimrc"
	mv "${HOME}/.vimrc" "${HOME}/._vimrc"
fi
stow vim
vim -c "PlugInstall" -c "visual" -c "qa"
