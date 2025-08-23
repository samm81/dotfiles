asdf_data_dir="${HOME}/.asdf"
if isinstalled 'asdf' && [[ -d "$asdf_data_dir" ]]; then
  export ASDF_DATA_DIR="$asdf_data_dir"
  export PATH="${ASDF_DATA_DIR}/shims:${PATH}"
fi
