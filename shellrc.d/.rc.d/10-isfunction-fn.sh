isfunction() {
  if type "$1" 2>/dev/null | grep -q 'function'; then
    return 0
  else
    return 1
  fi
}
