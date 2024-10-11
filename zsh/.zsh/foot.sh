foot_config="$HOME/.config/foot/foot.ini"
foot_bgcolor="$(grep '^background' "$foot_config" | cut -d ' ' -f 3)"
export SIXEL_BGCOLOR="#$foot_bgcolor"
