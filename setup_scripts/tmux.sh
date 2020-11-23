#!/usr/bin/env bash
# shellcheck source=../util/header.sh
. util/header.sh

check_installed stow
check_installed tmux

if [[ -f "${HOME}/.tmux.conf" ]]; then
	echo "existing .tmux.conf file detected, moving it to ~/._tmux.conf"
	mv "${HOME}/.tmux.conf" "${HOME}/._tmux.conf"
fi
stow tmux

# tmux pacakge manager
#git clone https://github.com/tmux-plugins/tpm tmux/.tmux/plugins/tpm

# tmuxp...?
