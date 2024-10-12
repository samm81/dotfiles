dropin() {
  local original new hint
  original="${1:?\`drop_in\` missing param 1 \`original\`}"
  new="${2:?\`drop_in\` missing param 2 \`new\`}"
  hint="${3:-dropping in ${new} for ${original}}"
  [ -n "$hint" ] && hint=">&2 echo ${hint};"
  # shellcheck disable=SC2139
  isinstalled "$new" &&
    alias "$original"="${hint}${new}"
}
