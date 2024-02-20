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

STATUSBAR_SH="$HOME/.config/sway/statusbar.sh"
X_RESOURCES="$HOME/.Xresources"

exists 'foot' && term='foot'
exists 'foot_randomize_theme' && term='foot-randomize-theme; foot'
! exists "$term" && echo 'No terminal found: missing `foot`' && exit 1

exists 'dmenu' && application_launcher='dmenu_path | dmenu | xargs swaymsg exec --'
[ -z "$application_launcher" ] \
  && echo 'No application launcher found: missing `dmenu`' \
  && exit 1

statusbar=$([ -x "$STATUSBAR_SH" ] && echo "true") || true
[ -n "$statusbar" ] && ! installed 'adwaita-icon-theme' \
  && echo 'err: `statusbar` depends on `adwaita-icon-theme`, but it is is not installed' \
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
set \$term-float $term --window-size-chars='120x60' --app-id='foot-float'
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
[ -n "$touchpad" ] && cat >> config <<EOF && echo "info: configured touchpad $touchpad"

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

! exists 'swaynagmode' && echo 'warn: could not find `swaynagmode`, skipping'
exists 'swaynagmode' && cat >> config <<EOF && echo 'info: added `swaynagmode`'

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
    # floating terminal
    bindsym \$mod+Shift+Return exec \$term-float

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

if ! exists 'swaynagmode'; then
  cat >> config <<EOF && echo 'info: added default exit binding'

    # Exit sway (logs you out of your Wayland session)
    bindsym \$mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
EOF
else
  cat >> config <<EOF && echo 'info: added `swaynagmode` exit binding'

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

#
# Status Bar:
#
# Read \`man 5 sway-bar\` for more information about this section.
bar {
    position top

    # When the status_command prints a new line to stdout, swaybar updates.
EOF

[ -z "$statusbar" ] || ! installed 'adwaita-icon-theme' \
  && echo 'warn: could not find `statusbar` or `adwaita-icon-theme` not installed, skipping'
if [ -n "$statusbar" ] && installed 'adwaita-icon-theme'; then
  cat >> config <<EOF && echo 'info: installed `statusbar.sh` as `status_command`'
    status_command while ~/.config/sway/statusbar.sh; do sleep 1; done

    # https://github.com/swaywm/sway/issues/5645
    icon_theme Adwaita
EOF
else
  cat >> config <<EOF && echo 'info: installed default `status_command`'
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

! exists 'pamixer' && echo 'warn: could not find `pamixer`, skipping volume keys'
exists 'pamixer' && cat >> config <<EOF && echo 'info: installed `pamixer` volume keys'

# special keys
# https://wiki.archlinux.org/title/Sway#Custom_keybindings

    bindsym XF86AudioRaiseVolume exec pamixer --increase 5
    bindsym XF86AudioLowerVolume exec pamixer --decrease 5
    bindsym XF86AudioMute exec pamixer --toggle-mute
EOF

! exists 'brillo' && echo 'warn: could not find `brillo`, skipping volume keys'
exists 'brillo' && cat >> config <<EOF && echo 'info: installed `brillo` backlight keys'
    bindsym XF86MonBrightnessUp exec brillo -u 200000 -A 5
    bindsym XF86MonBrightnessDown exec brillo -u 200000 -U 5
    bindsym XF86Display exec "[ \$(brillo -G | cut -d '.' -f 1) != '0' ] && brillo -O && brillo -u 800000 -S 0 && swaymsg 'output * dpms off' || (swaymsg 'output * dpms on' && brillo -u 800000 -I)"
EOF

! exists 'mako' && echo 'warn: could not find `mako`, skipping'
exists 'mako' && cat <<EOF >> config && echo 'info: installed `mako` dismiss binding'

# mako notifications
# https://github.com/emersion/mako
    bindsym \$mod+o exec makoctl dismiss
EOF

! exists 'swaylock' && echo 'warn: could not find `swaylock`, skipping'
exists 'swaylock' && cat <<EOF >> config && echo 'info: installed `swaylock` binding'

# swaylock ((i)dle)
    bindsym \$mod+i exec 'swaylock -f -e -c 000000DD'
EOF

! exists 'grimshot' && echo 'warn: could not find `grimshot`, skipping'
exists 'grimshot' && cat <<EOF >> config && echo 'info: installed `grimshot` bindings'

# grimshot
    bindsym \$mod+p exec grimshot copy area
    bindsym \$mod+Shift+p exec grimshot copy active
    bindsym \$mod+Ctrl+p exec grimshot copy screen
EOF

! exists 'wifi' && echo 'warn: could not find `wifi`, skipping'
exists 'wifi' && cat <<EOF >> config && echo 'info: installed `wifi` bindings'

# wifi
    bindsym \$mod+Shift+w exec \$term-float 'wifi'
EOF

! exists 'insect' && echo 'warn: could not find `insect`, skipping'
exists 'insect' && cat <<EOF >> config && echo 'info: installed `insect` bindings'

# calculator
    bindsym \$mod+bracketleft exec \$term-float 'insect'
EOF

! exists 'wofi-emoji' && echo 'warn: could not find `wofi-emoji`, skipping'
exists 'wofi-emoji' && cat <<EOF >> config && echo 'info: installed `wofi-emoji` bindings'

# emoji
    bindsym \$mod+semicolon exec wofi-emoji
EOF

cat <<EOF >> config && echo 'info: installed floating window directives'

for_window [app_id="foot-float"] floating enable
for_window [app_id="zoom" title="zoom"] floating enable
for_window [class="Anki" title="add"] floating enable
for_window [title="win0"] floating enable
for_window [title="Firefox — Sharing Indicator"] \\
    floating enable \\
  , resize set width 79px height 52px \\
  , move position 2250px 5px
for_window [app_id="anki"] floating enable
for_window [class="vlc"] floating enable
EOF

cat <<EOF >> config && echo 'info: installed second monitor config, assuming `eDP-1` is primary'

# second monitor
    bindsym \$mod+m exec 'swaymsg output eDP-1 toggle'
    bindsym \$mod+Ctrl+Shift+\$left exec 'swaymsg move workspace output left'
    bindsym \$mod+Ctrl+Shift+\$down exec 'swaymsg move workspace output down'
    bindsym \$mod+Ctrl+Shift+\$up exec 'swaymsg move workspace output up'
    bindsym \$mod+Ctrl+Shift+\$right exec 'swaymsg move workspace output right'
EOF

cat <<EOF >> config && echo 'info: installed `dbus` env variable fix'

# on startup
    # https://github.com/emersion/xdg-desktop-portal-wlr#running
    # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
    exec dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway SWAYSOCK
EOF

cat <<EOF >> config && echo 'info: installed sway-sv kickoff'
    exec runsvdir "\$SWAY_SVDIR"
EOF

xresources=$([ -f "$X_RESOURCES" ] && echo 'true') || true
[ -z "$xresources" ] && echo "warn: \`$X_RESOURCES\` file is missing, skipping, might have dpi problems"
[ -n "$xresources" ] && cat >> config <<EOF && echo "info: loading \`$X_RESOURCES\` file on startup"
    # https://github.com/swaywm/sway/wiki#after-unplugging-an-external-display-some-applications-appear-too-large-on-my-hidpi-screen
    exec xrdb -load ~/.Xresources
EOF

exists 'mako' && cat >> config <<EOF && echo 'info: loading `mako` on startup'
    exec mako
EOF

! exists 'pipewire' && echo 'warn: could not find `pipewire`, skipping'
exists 'pipewire' && cat >> config <<EOF && echo 'info: loading `pipewire` on startup'
    exec pipewire
EOF

! exists 'pipewire_pulse' && echo 'warn: could not find `pipewire-pulse`, skipping'
exists 'pipewire_pulse' && cat >> config <<EOF && echo 'info: loading `pipewire-pulse` on startup'
    exec pipewire-pulse
EOF

#! exists 'fcitx5' && echo 'warn: could not find `fcitx5`, skipping'
#exists 'fcitx5' && cat >> config <<EOF && echo 'info: loading `fcitx5` on startup'
#    exec fcitx5 -d --replace
#EOF

! exists 'kanshi' && echo 'warn: could not find `kanshi`, skipping'
exists 'kanshi' && cat >> config <<EOF && echo 'info: loading `kanshi` on startup'
    exec kanshi
EOF

! exists 'udiskie' && echo 'warn: could not find `udiskie`, skipping'
exists 'udiskie' && cat >> config <<EOF && echo 'info: loading `udiskie` on startup'
    exec udiskie
EOF

! exists 'gammastep' && echo 'warn: could not find `gammastep`, skipping'
exists 'gammastep' && cat >> config <<EOF && echo 'info: loading `gammastep` on startup'
    exec_always \
      notify-send '[sway-startup] reminder ‼️ \`gammastep\` is perma-on' \
      ; pkill 'gammastep' \
      ; gammastep -O 4500
EOF

cat <<EOF >> config

include /etc/sway/config.d/*
EOF

echo "all done, remember to reload config"

# discovered with `wev`
# XF86AudioMicMute
# XF86MonBrightnessDown
# XF86MonBrightnessUp
# XF86Display
# XF86WLAN
# XF86NotificationCenter
# XF86PickupPhone
# XF86HangupPhone
# XF86Favorites
# Print
