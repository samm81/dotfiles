export XDG_CURRENT_DESKTOP='sway'
export XDG_SESSION_TYPE='wayland'
export QT_QPA_PLATFORM='wayland'
# https://github.com/swaywm/sway/wiki#issues-with-java-applications
# https://github.com/swaywm/sway/issues/595
export _JAVA_AWT_WM_NONREPARENTING=1
# https://github.com/swaywm/sway/wiki#i-cant-open-links-in-external-applications-in-firefox
export MOZ_DBUS_REMOTE=1
# https://github.com/swaywm/sway/wiki#disabling-client-side-qt-decorations
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

export MOZ_ENABLE_WAYLAND=1

# https://github.com/fcitx/fcitx5/issues/39#issuecomment-680018648
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

export SWAY_SVDIR="$HOME/service-sway"

if [ "$(tty)" = "/dev/tty2" ]; then
  XDG_RUNTIME_DIR="/tmp/xdg-runtime-$(id -u)"
	export XDG_RUNTIME_DIR
  [ ! -d "XDG_RUNTIME_DIR" ] && mkdir "$XDG_RUNTIME_DIR" && chmod 0700 "$XDG_RUNTIME_DIR"
  dbus-run-session sway
  # post sway cleanup is handled by elogind
  # make sure to set `KillUserProcesses=yes` in `logind.conf`
fi

alias visway="vim -O $HOME/.config/sway/config $HOME/.config/sway/configure.sh"
