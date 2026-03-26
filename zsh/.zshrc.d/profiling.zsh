# lightweight startup benchmark:
#   zsh-profile-startup --detail
zsh_profile_startup() {
  if command -v zsh-profile-startup >/dev/null 2>&1; then
    command zsh-profile-startup "$@"
    return
  fi

  print -u2 -r -- 'zsh-profile-startup is not on PATH'
  return 1
}

# deeper xtrace + zprof instrumentation for one-off debugging
# https://esham.io/2018/02/zsh-profiling
profile_start() {
  zmodload zsh/datetime
  setopt PROMPT_SUBST
  PS4='+$EPOCHREALTIME %N:%i> '

  logfile=$(mktemp zsh_profile.XXXXXXXX)
  echo "Logging to $logfile"
  exec 3>&2 2>"$logfile"

  setopt XTRACE

  zmodload zsh/zprof
}

profile_stop() {
  unsetopt XTRACE
  exec 2>&3 3>&-

  zprof
}
