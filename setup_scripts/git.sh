#!/usr/bin/env bash
# shellcheck source=../util/header.sh
. util/header.sh

check_installed "stow"
stow git
