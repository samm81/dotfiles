#!/usr/bin/env bash
# shellcheck source=../util/header.sh
. util/header.sh

check_installed zsh
check_installed git
check_installed stow

stow zsh

# Prevent the cloned repositories from having insecure permissions. Failing to
# do so causes compinit() calls to fail with "command not found: compdef" errors
# for users with insecure umasks (e.g., "002", allowing group writability). Note
# that this will be ignored under Cygwin by default, as Windows ACLs take
# precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

# oh-my-zsh
# https://github.com/robbyrussell/oh-my-zsh
# adapted from https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
if [[ ! -n "${ZSH-}" ]]; then
	ZSH=~/.oh-my-zsh
fi

if [[ -d "${ZSH}" ]]; then
	echo "You already have Oh My Zsh installed."
	echo "You'll need to remove ${ZSH} if you want to re-install."
else
	env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "${ZSH}"
fi

# If this user's login shell is not already "zsh", attempt to switch.
TEST_CURRENT_SHELL="$(expr "${SHELL}" : '.*/\(.*\)')"
if test "${TEST_CURRENT_SHELL}" != "zsh"; then
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

# custom plugins
ZSH_CUSTOM="${ZSH}/custom"

function install_zsh_plugin {
    plugin_url="${1}"
    plugin_name="${plugin_url##*/}"
    plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"
    if [[ -d "${plugin_dir}" ]]; then
        echo "${plugin_name} already installed, skipping..."
    else
        echo "installing ${plugin_name} to ${plugin_dir}"
        env git clone --depth=1 "${plugin_url}" "${plugin_dir}"
    fi
}

# zsh-autosuggestions for fish like suggestions
install_zsh_plugin 'https://github.com/zsh-users/zsh-autosuggestions'

# zsh-completions for... more completions I guess
install_zsh_plugin 'https://github.com/zsh-users/zsh-completions'

# zsh-syntax-highlighting for fish like highlighting
install_zsh_plugin 'https://github.com/zsh-users/zsh-syntax-highlighting'

# zsh-auto-notify to notify when long running commands complete
install_zsh_plugin 'https://github.com/MichaelAquilina/zsh-auto-notify'
# zsh-auto-notify is a special snowflake that wants to be called just "auto-notify"
# but this breaks importing
AUTO="${ZSH_CUSTOM}/plugins/zsh-auto-notify/auto-notify.plugin.zsh"
ZSH_AUTO="${ZSH_CUSTOM}/plugins/zsh-auto-notify/zsh-auto-notify.plugin.zsh"
[[ -e "$AUTO" ]] && mv "$AUTO" "$ZSH_AUTO"

echo "done!"
