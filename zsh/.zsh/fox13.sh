export IWD_DIR=/var/lib/iwd

export BROWSER="firefox-wayland"

# ideally read this from ~/.config/foot.ini
foot_config="$HOME/.config/foot/foot.ini"
foot_bgcolor="$(grep '^background' "$foot_config" | cut -d ' ' -f 3)"
export SIXEL_BGCOLOR="#$foot_bgcolor"

export SVDIR="$HOME/service"

export ICONS_DIR="$HOME/icons/svgs"
