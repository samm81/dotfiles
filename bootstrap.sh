#!/usr/bin/env bash

# This script just calls stow on various subdirectories, depending on either input parameters or operating systems
function install_vim_plug () {
    if [[ ! -f vim/.vim/autoload/plug.vim ]]; then
        curl -fLo vim/.vim/autoload/plug.vim --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
}

# go to the right directory
pushd $(dirname "${BASH_SOURCE}") > /dev/null

install_vim_plug
for package in $(ls -d */); do
	stow $package;
done

popd > /dev/null
