#!/usr/bin/env bash

check_installed stow
check_installed curl

if [[ -f "${HOME}/.vimrc" ]]; then
  echo "existing .vimrc file detected, moving it to ~/.vimrc.bak"
  mv "${HOME}/.vimrc" "${HOME}/.vimrc.bak"
fi
stow vim
vim -c "PlugInstall" -c "visual" -c "qa"
