#!/usr/bin/env bash
. util/header.sh

check_installed zsh
check_installed git
check_installed stow

stow zsh

# oh-my-zsh
# https://github.com/robbyrussell/oh-my-zsh
# adapted from https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
if ! test -n "${ZSH-}"; then
	ZSH=~/.oh-my-zsh
fi

if test -d "$ZSH"; then
	echo "You already have Oh My Zsh installed."
	echo "You'll need to remove $ZSH if you want to re-install."
	exit
fi

# Prevent the cloned repository from having insecure permissions. Failing to do
# so causes compinit() calls to fail with "command not found: compdef" errors
# for users with insecure umasks (e.g., "002", allowing group writability). Note
# that this will be ignored under Cygwin by default, as Windows ACLs take
# precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$ZSH"

# If this user's login shell is not already "zsh", attempt to switch.
TEST_CURRENT_SHELL="$(expr "$SHELL" : '.*/\(.*\)')"
if test "$TEST_CURRENT_SHELL" != "zsh"; then
	# If this platform provides a "chsh" command (not Cygwin), do it, man!
	if hash chsh >/dev/null 2>&1; then
		echo "Time to change your default shell to zsh!"
		chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
	# Else, suggest the user do so manually.
	else
		echo "I can't change your shell automatically because this system does not have chsh."
		echo "Please manually change your default shell to zsh!"
	fi
fi

# k is the new l
# https://github.com/supercrabtree/k
ZSH_CUSTOM="$ZSH/custom"
git clone --depth=1 https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
