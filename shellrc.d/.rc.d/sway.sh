if isinstalled 'sway'; then
  SVDIR_SWAY="$HOME/service-sway"
  [[ -d "$SVDIR_SWAY" ]] && export SVDIR_SWAY
  sway_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sway"
  alias visway="vim -O \$HOME/.config/sway/config \$HOME/.config/sway/configure.sh; ${sway_config_dir}/configure.sh"
fi
