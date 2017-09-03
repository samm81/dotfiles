#!/usr/bin/env bash
set -e
set -x

function install_vim_plug () {
	if [[ ! -f vim/.vim/autoload/plug.vim ]]; then
		curl -fLo vim/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	fi
}

# go to the right directory
pushd $(dirname "${BASH_SOURCE}")

git submodule init
git submodule update

# powerline
sudo apt-get install python-pip3
sudo pip3 install powerline-status
stow powerline
sudo apt-get install fontconfig
fc-cache -vf ~/.fonts/

# have to install zsh first so that fzf will install appropriately
sudo apt-get install zsh

install_vim_plug
stow vim
# runs PlugInstall in vim to get all plugins, also gets fzf since fzf is a vim plugin too
vim -c "PlugInstall" -c "visual" -c "qa"

# zsh
if [[ -f $HOME/.zshrc ]]; then
	mv $HOME/.zshrc $HOME/._zshrc
fi
stow zsh
mkdir -p $HOME/.oh-my-zsh/custom/plugins/fzf/
ln -s $HOME/.fzf.zsh $HOME/.oh-my-zsh/custom/plugins/fzf/fzf.plugin.zsh
stow k

# tmux
sudo apt-get install tmux
stow tmux
tmux new "$HOME/.tmux/plugins/tpm/bindings/install_plugins"
sudo pip install tmuxp

if [[ -f $HOME/.bashrc ]]; then
	mv $HOME/.bashrc $HOME/._bashrc
fi
stow bash

stow git

popd
