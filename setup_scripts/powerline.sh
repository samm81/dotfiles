#!/usr/bin/env bash
# shellcheck source=../util/header.sh
. util/header.sh

check_installed pip3
check_installed fc-cache
check_installed stow

pip3 install --user powerline-status
stow powerline
fc-cache -vf ~/.fonts/
