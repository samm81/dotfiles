#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

exists() {
  executable="$1"
  test "$(command -v "$executable")"
}
installed() {
  package="$1"
  xbps-query "$package" > /dev/null
}

CONFIG="config"
STATUSBAR_SH="$HOME/.config/sway/statusbar.sh"
X_RESOURCES="$HOME/.Xresources"

foot=$(exists foot && echo 'true') || true
foot_randomize_theme=$(exists foot-randomize-theme && echo 'true') || true
dmenu=$(exists dmenu && echo 'true') || true
swaynagmode=$(exists swaynagmode && echo 'true') || true
statusbar=$([ -x "$STATUSBAR_SH" ] && echo 'true') || true
adwaita=$(installed adwaita-icon-theme && echo 'true') || true
pamixer=$(exists pamixer && echo 'true') || true
mako=$(exists mako && echo 'true') || true
swaylock=$(exists swaylock && echo 'true') || true
grimshot=$(exists grimshot && echo 'true') || true
xresources=$([ -f "$X_RESOURCES" ] && echo 'true') || true
pipewire=$(exists pipewire && echo 'true') || true
pipewire_pulse=$(exists pipewire-pulse && echo 'true') || true
gammastep=$(exists gammastep && echo 'true') || true
syncthing=$(exists syncthing && echo 'true') || true
fcitx5=$(exists fcitx5 && echo 'true') || true

[ -n "$foot" ] && term='foot'
[ -n "$foot_randomize_theme" ] && term='foot-randomize-theme; foot'
[ -z "$term" ] && echo 'No terminal found: missing `foot`' && exit 1

[ -n "$dmenu" ] && application_launcher='dmenu_path | dmenu | xargs swaymsg exec --'
[ -z "$application_launcher" ] \
  && echo 'No application launcher found: missing `dmenu`' \
  && exit 1

[ -n "$statusbar" ] && [ -z "$adwaita" ] \
  && echo 'err: `statusbar` depends on `adwaita`, but `adwaita-icon-theme` is not installed' \
  && exit 1

cat <<EOF > config
# \`man 5 sway\`

### Variables
#
# Logo key. Use Mod1 for Alt.
set \$mod Mod4
# Home row direction keys, like vim
set \$left h
set \$down j
set \$up k
set \$right l
# Your preferred terminal emulator
set \$term $term
# Your preferred application launcher
# Note: pass the final command to swaymsg so that the resulting window can be opened
# on the original workspace that the command was run on.
set \$menu $application_launcher

### Output configuration
#
# Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
output * bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill
#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs

### Idle configuration
#
# Example configuration:
#
# exec swayidle -w \\
#          timeout 300 'swaylock -f -c 000000' \\
#          timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \\
#          before-sleep 'swaylock -f -c 000000'
#
# This will lock your screen after 300 seconds of inactivity, then turn off
# your displays after another 300 seconds, and turn your screens back on when
# resumed. It will also lock your screen before your computer goes to sleep.
EOF

touchpad=$(swaymsg -t get_inputs | grep 'Touchpad' | grep 'identifier' | cut -d '"' -f 4)
[ -z "$touchpad" ] && echo 'warn: could not find a touchpad, skipping'
[ -n "$touchpad" ] && cat <<EOF >> config

### Input configuration
# You can get the names of your inputs by running: swaymsg -t get_inputs
# Read \`man 5 sway-input\` for more information about this section.
input "$touchpad" {
    accel_profile adaptive
    drag enabled
    dwt disabled
    tap enabled
}
EOF

[ -z "$swaynagmode" ] && echo 'warn: could not find `swaynagmode`, skipping'
[ -n "$swaynagmode" ] && cat <<EOF >> config

# swaynagmode
set \$nag         exec swaynagmode
set \$nag_exit    \$nag --exit
set \$nag_confirm \$nag --confirm
set \$nag_select  \$nag --select
mode "nag" {
    bindsym {
        Ctrl+d    mode "default"

        Ctrl+c    \$nag_exit
        q         \$nag_exit
        Escape    \$nag_exit

        Return    \$nag_confirm

        Tab       \$nag_select prev
        Shift+Tab \$nag_select next

        Left      \$nag_select next
        Right     \$nag_select prev

        Up        \$nag_select next
        Down      \$nag_select prev
    }
}
# -R is recommended for swaynag_command so that, upon a syntax error in your sway config, the
# 'Reload Sway' option will be initially selected instead of the 'Exit Sway' option
swaynag_command \$nag -R
EOF

cat <<EOF >> config

### Key bindings
#
# Basics:
#
    # Start a terminal
    bindsym \$mod+Return exec \$term

    # Kill focused window
    bindsym \$mod+Shift+q kill

    # Start your launcher
    bindsym \$mod+d exec \$menu

    # Drag floating windows by holding down \$mod and left mouse button.
    # Resize them with right mouse button + \$mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier \$mod normal

    # Reload the configuration file
    bindsym \$mod+Shift+c reload
EOF

if [ -z "$swaynagmode" ]; then
  cat <<EOF >> config

    # Exit sway (logs you out of your Wayland session)
    bindsym \$mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
EOF
else
  cat <<EOF >> config

    # Exit sway (logs you out of your Wayland session)
    bindsym \$mod+Shift+e \$nag -t "warning" -m "Exit Sway?" -b "Exit" "swaymsg exit" -b "Reload" "swaymsg reload"
EOF
fi

cat <<EOF >> config

#
# Moving around:
#
    # Move your focus around
    bindsym \$mod+\$left focus left
    bindsym \$mod+\$down focus down
    bindsym \$mod+\$up focus up
    bindsym \$mod+\$right focus right
    # Or use \$mod+[up|down|left|right]
    bindsym \$mod+Left focus left
    bindsym \$mod+Down focus down
    bindsym \$mod+Up focus up
    bindsym \$mod+Right focus right

    # Move the focused window with the same, but add Shift
    bindsym \$mod+Shift+\$left move left
    bindsym \$mod+Shift+\$down move down
    bindsym \$mod+Shift+\$up move up
    bindsym \$mod+Shift+\$right move right
#
# Workspaces:
#
    # Switch to workspace
    bindsym \$mod+1 workspace number 1
    bindsym \$mod+2 workspace number 2
    bindsym \$mod+3 workspace number 3
    bindsym \$mod+4 workspace number 4
    bindsym \$mod+5 workspace number 5
    bindsym \$mod+6 workspace number 6
    bindsym \$mod+7 workspace number 7
    bindsym \$mod+8 workspace number 8
    bindsym \$mod+9 workspace number 9
    bindsym \$mod+0 workspace number 10
    # Move focused container to workspace
    bindsym \$mod+Shift+1 move container to workspace number 1
    bindsym \$mod+Shift+2 move container to workspace number 2
    bindsym \$mod+Shift+3 move container to workspace number 3
    bindsym \$mod+Shift+4 move container to workspace number 4
    bindsym \$mod+Shift+5 move container to workspace number 5
    bindsym \$mod+Shift+6 move container to workspace number 6
    bindsym \$mod+Shift+7 move container to workspace number 7
    bindsym \$mod+Shift+8 move container to workspace number 8
    bindsym \$mod+Shift+9 move container to workspace number 9
    bindsym \$mod+Shift+0 move container to workspace number 10
    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-10 as the default.
    bindsym \$mod+tab workspace back_and_forth
#
# Layout stuff:
#
    # You can "split" the current object of your focus with
    # \$mod+b or \$mod+v, for horizontal and vertical splits
    # respectively.
    bindsym \$mod+b splith
    bindsym \$mod+v splitv

    # Switch the current container between different layout styles
    bindsym \$mod+s layout stacking
    bindsym \$mod+w layout tabbed
    bindsym \$mod+e layout toggle split

    # Make the current focus fullscreen
    bindsym \$mod+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym \$mod+Shift+space floating toggle

    # Swap focus between the tiling area and the floating area
    bindsym \$mod+space focus mode_toggle

    # Move focus to the parent container
    bindsym \$mod+a focus parent
#
# Scratchpad:
#
    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym \$mod+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym \$mod+minus scratchpad show
#
# Resizing containers:
#
mode "resize" {
    # left will shrink the containers width
    # right will grow the containers width
    # up will shrink the containers height
    # down will grow the containers height
    bindsym \$left resize shrink width 10px
    bindsym \$down resize grow height 10px
    bindsym \$up resize shrink height 10px
    bindsym \$right resize grow width 10px

    # Return to default mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym \$mod+r mode "resize"
EOF

cat <<EOF >> config

#
# Status Bar:
#
# Read \`man 5 sway-bar\` for more information about this section.
bar {
    position top

    # When the status_command prints a new line to stdout, swaybar updates.
EOF

[ -z "$statusbar" ] || [ -z "$adwaita" ] \
  && echo 'warn: could not find `statusbar` or `adwaita` not installed, skipping'
if [ -n "$statusbar" ] && [ -n "$adwaita" ]; then
  cat <<EOF >> config
    status_command while ~/.config/sway/statusbar.sh; do sleep 1; done

    # https://github.com/swaywm/sway/issues/5645
    icon_theme Adwaita
EOF
else
  cat <<EOF >> config
    # The default just shows the current date and time.
    status_command while date +'%Y-%m-%d %l:%M:%S %p'; do sleep 1; done
EOF
fi

cat <<EOF >> config

    colors {
        statusline #ffffff
        background #323232
        inactive_workspace #32323200 #32323200 #5c5c5c
    }
}

default_border pixel 1
smart_borders on
gaps inner 1
smart_gaps on
EOF

[ -z "$pamixer" ] && echo 'warn: could not find `pamixer`, skipping volume keys'
[ -n "$pamixer" ] && cat <<EOF >> config

# special keys
# https://wiki.archlinux.org/title/Sway#Custom_keybindings

    bindsym XF86AudioRaiseVolume exec pamixer --increase 5
    bindsym XF86AudioLowerVolume exec pamixer --decrease 5
    bindsym XF86AudioMute exec pamixer --toggle-mute
EOF

[ -z "$mako" ] && echo 'warn: could not find `mako`, skipping'
[ -n "$mako" ] && cat <<EOF >> config

# mako notifications
# https://github.com/emersion/mako
    bindsym \$mod+o exec makoctl dismiss
EOF

[ -z "$swaylock" ] && echo 'warn: could not find `swaylock`, skipping'
[ -n "$swaylock" ] && cat <<EOF >> config

# swayidle
    bindsym \$mod+i exec 'swaylock -f -e -c 000000DD'
EOF

[ -z "$grimshot" ] && echo 'warn: could not find `grimshot`, skipping'
[ -n "$grimshot" ] && cat <<EOF >> config

# grimshot
    bindsym \$mod+p exec grimshot copy area
    bindsym \$mod+Shift+p exec grimshot copy active
    bindsym \$mod+Ctrl+p exec grimshot copy screen
EOF

cat <<EOF >> config

for_window [app_id="zoom" title="zoom"] floating enable
for_window [class="Anki" title="add"] floating enable
for_window [title="win0"] floating enable

# second monitor
    bindsym \$mod+m exec 'swaymsg output eDP-1 toggle'
    bindsym \$mod+Ctrl+Shift+\$left exec 'swaymsg move workspace output left'
    bindsym \$mod+Ctrl+Shift+\$down exec 'swaymsg move workspace output down'
    bindsym \$mod+Ctrl+Shift+\$up exec 'swaymsg move workspace output up'
    bindsym \$mod+Ctrl+Shift+\$right exec 'swaymsg move workspace output right'

# on startup
    # https://github.com/emersion/xdg-desktop-portal-wlr#running
    # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
    exec dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway SWAYSOCK
EOF

[ -z "$xresources" ] && echo "warn: \`$X_RESOURCES\` file is missing, skipping, might have dpi problems"
[ -n "$xresources" ] && cat <<EOF >> config
    # https://github.com/swaywm/sway/wiki#after-unplugging-an-external-display-some-applications-appear-too-large-on-my-hidpi-screen
    exec xrdb -load ~/.Xresources
EOF

[ -n "$mako" ] && cat <<EOF >> config
    exec mako
EOF

[ -z "$pipewire" ] && echo 'warn: could not find `pipewire`, skipping'
[ -n "$pipewire" ] && cat <<EOF >> config
    exec pipewire
EOF

[ -z "$pipewire_pulse" ] && echo 'warn: could not find `pipewire-pulse`, skipping'
[ -n "$pipewire_pulse" ] && cat <<EOF >> config
    exec pipewire-pulse
EOF

[ -z "$gammastep" ] && echo 'warn: could not find `gammastep`, skipping'
[ -n "$gammastep" ] && cat <<EOF >> config
    exec gammastep -l 47.7:-122.3 -b 1:0.5
EOF

[ -z "$syncthing" ] && echo 'warn: could not find `syncthing`, skipping'
[ -n "$syncthing" ] && cat <<EOF >> config
    exec syncthing --no-browser
EOF

[ -z "$fcitx5" ] && echo 'warn: could not find `fcitx5`, skipping'
[ -n "$fcitx5" ] && cat <<EOF >> config
    exec fcitx5 -d --replace
EOF

cat <<EOF >> config

include /etc/sway/config.d/*
EOF

echo "all done, remember to reload config"
