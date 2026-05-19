#!/usr/bin/env bash

check_installed pip3
check_installed fc-cache
check_installed stow

pip3 install --user powerline-status
stow powerline
fc-cache -vf ~/.fonts/
