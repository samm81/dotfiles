if isinstalled 'sway'; then
  SVDIR_SWAY="$HOME/service-sway"
  [[ -d "$SVDIR_SWAY" ]] && export SVDIR_SWAY
  sway_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sway"
  alias visway="cd ${sway_config_dir}; vim -O config configure.sh; ./configure.sh; cd -"
fi
