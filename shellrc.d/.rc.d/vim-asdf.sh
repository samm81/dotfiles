tool_versions="${HOME}/.tool-versions"
if [[ -d "$tool_versions" ]] ; then
  export ASDF_NODEJS_GLOBAL_VERSION=$(grep 'nodejs' "$tool_versions" | cut -d ' ' -f 2)
  alias vim='ASDF_NODEJS_VERSION="$ASDF_NODEJS_GLOBAL_VERSION" vim'
fi
