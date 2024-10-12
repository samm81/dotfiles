if isinstalled 'sway'; then
  SWAY_SVDIR="$HOME/service-sway"
  [[ -d "$SWAY_SVDIR" ]] && export SWAY_SVDIR
  alias visway="vim -O \$HOME/.config/sway/config \$HOME/.config/sway/configure.sh"
fi
