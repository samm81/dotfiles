foot_config="$HOME/.config/foot/foot.ini"
if [[ -e "$foot_config" ]]; then
  foot_bgcolor="$(grep '^background' "$foot_config" | cut -d ' ' -f 3)"
  export SIXEL_BGCOLOR="#${foot_bgcolor}"
fi
