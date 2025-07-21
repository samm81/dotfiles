tool_versions="${HOME}/.tool-versions"
if [[ -e "$tool_versions" ]]; then
  ASDF_NODEJS_GLOBAL_VERSION="$(grep 'nodejs' "$tool_versions" | cut -d ' ' -f 2)"
  export ASDF_NODEJS_GLOBAL_VERSION
fi
