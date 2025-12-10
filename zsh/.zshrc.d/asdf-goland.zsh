# https://github.com/asdf-community/asdf-golang/blob/50c8f58237da34223d31ac9e62e5d5f8dcc13f5f/README.md#use
asdf_golang_env_file="${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh"
if [[ -e "$asdf_golang_env_file" ]]; then
  . "$asdf_golang_env_file"
fi
