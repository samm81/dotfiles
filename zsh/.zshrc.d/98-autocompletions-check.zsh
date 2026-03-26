zmodload zsh/datetime 2>/dev/null || true

autoload -Uz add-zsh-hook

_zac_runtime_mode() {
  if [[ -n "${ZSH_AUTOCOMPLETIONS_MODE:-}" ]]; then
    print -r -- "$ZSH_AUTOCOMPLETIONS_MODE"
    return
  fi

  local value
  if zstyle -s ':zsh-autocompletions:' mode value; then
    print -r -- "$value"
    return
  fi

  print -r -- 'prompt'
}

_zac_runtime_days() {
  local value

  if [[ -n "${ZSH_AUTOCOMPLETIONS_DAYS:-}" ]]; then
    value="$ZSH_AUTOCOMPLETIONS_DAYS"
  elif zstyle -s ':zsh-autocompletions:' days value; then
    :
  else
    value=7
  fi

  [[ "$value" == <-> ]] || value=7
  (( value > 0 )) || value=7
  print -r -- "$value"
}

_zac_runtime_verbosity() {
  local value

  if [[ -n "${ZSH_AUTOCOMPLETIONS_VERBOSITY:-}" ]]; then
    value="$ZSH_AUTOCOMPLETIONS_VERBOSITY"
  elif zstyle -s ':zsh-autocompletions:' verbosity value; then
    :
  else
    value=1
  fi

  [[ "$value" == <-> ]] || value=1
  print -r -- "$value"
}

_zac_runtime_lock_age_seconds() {
  zmodload -F zsh/stat b:zstat 2>/dev/null || return 1

  local -A stat_info
  zstat -A stat_info +mtime -- "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" 2>/dev/null || return 1
  print -r -- $(( EPOCHSECONDS - stat_info[mtime] ))
}

_zac_runtime_release_lock() {
  [[ -d "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" ]] || return 0

  command rm -f -- "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/pid" "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/started_at" 2>/dev/null
  rmdir "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" 2>/dev/null
}

_zac_runtime_release_any_lock() {
  if typeset -f _zac_release_lock >/dev/null 2>&1; then
    _zac_release_lock
    return
  fi

  _zac_runtime_release_lock
}

_zac_runtime_acquire_lock() {
  local stale_after="${ZSH_AUTOCOMPLETIONS_LOCK_STALE_SECONDS:-21600}"
  local age

  if ! command mkdir -p -- "$ZSH_AUTOCOMPLETIONS_LOCK_ROOT" 2>/dev/null; then
    ZSH_AUTOCOMPLETIONS_LOCK_ROOT="$ZSH_AUTOCOMPLETIONS_CACHE_DIR"
    ZSH_AUTOCOMPLETIONS_LOCK_DIR="${ZSH_AUTOCOMPLETIONS_LOCK_ROOT}/autocompletions.lock"
    command mkdir -p -- "$ZSH_AUTOCOMPLETIONS_LOCK_ROOT" || return 1
  fi

  if command mkdir -- "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" 2>/dev/null; then
    print -r -- "$$" >| "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/pid"
    print -r -- "$EPOCHSECONDS" >| "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/started_at"
    return 0
  fi

  age="$(_zac_runtime_lock_age_seconds)" || return 1
  (( age >= stale_after )) || return 1

  command rm -f -- "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/pid" "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/started_at" 2>/dev/null
  rmdir "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" 2>/dev/null || return 1
  command mkdir -- "$ZSH_AUTOCOMPLETIONS_LOCK_DIR" 2>/dev/null || return 1
  print -r -- "$$" >| "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/pid"
  print -r -- "$EPOCHSECONDS" >| "$ZSH_AUTOCOMPLETIONS_LOCK_DIR/started_at"
}

_zac_runtime_load_library() {
  [[ -n "${_ZAC_RUNTIME_LIBRARY_LOADED:-}" ]] && return 0

  # shellcheck disable=SC1090
  source "${ZSH_AUTOCOMPLETIONS_CONFIG_DIR}/lib/autocompletions.zsh" || {
    print -u2 -r -- "zsh-autocompletions: missing ${ZSH_AUTOCOMPLETIONS_CONFIG_DIR}/lib/autocompletions.zsh"
    return 1
  }

  _ZAC_RUNTIME_LIBRARY_LOADED=1
}

_zac_runtime_due_hook() {
  local reply=''

  add-zsh-hook -d precmd _zac_runtime_due_hook

  case "$_ZAC_RUNTIME_MODE" in
    reminder)
      print -r -- 'zsh completions are stale; run `zrefresh-completions` to refresh them.'
      _zac_runtime_load_library && zac_touch_stamp "$_ZAC_RUNTIME_MODE" "$_ZAC_RUNTIME_VERBOSITY"
      _zac_runtime_release_any_lock
      ;;
    prompt)
      read -q "reply?zsh completions are stale. refresh now? [y/N] "
      print
      if [[ "$reply" == [Yy] ]]; then
        _zac_runtime_load_library && zac_refresh_with_lock "$_ZAC_RUNTIME_MODE" "$_ZAC_RUNTIME_VERBOSITY"
      else
        _zac_runtime_load_library && zac_touch_stamp "$_ZAC_RUNTIME_MODE" "$_ZAC_RUNTIME_VERBOSITY"
      fi
      _zac_runtime_release_any_lock
      ;;
    background)
      _zac_runtime_load_library || {
        _zac_runtime_release_any_lock
        return
      }

      {
        zac_refresh_with_lock "$_ZAC_RUNTIME_MODE" "$_ZAC_RUNTIME_VERBOSITY"
        _zac_release_lock
      } >/dev/null 2>&1 &!
      ;;
    *)
      _zac_runtime_release_any_lock
      ;;
  esac
}

_zac_runtime_last_epoch=0
if [[ -r "$ZSH_AUTOCOMPLETIONS_STAMP_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ "$key" == 'LAST_EPOCH' ]] || continue
    _zac_runtime_last_epoch="${value//[^0-9]/}"
    break
  done < "$ZSH_AUTOCOMPLETIONS_STAMP_FILE"
fi

_ZAC_RUNTIME_MODE="$(_zac_runtime_mode)"
[[ "$_ZAC_RUNTIME_MODE" == 'disabled' ]] && return

_zac_runtime_days="$(_zac_runtime_days)"
if (( EPOCHSECONDS - _zac_runtime_last_epoch < _zac_runtime_days * 86400 )); then
  return
fi

_ZAC_RUNTIME_VERBOSITY="$(_zac_runtime_verbosity)"
_zac_runtime_acquire_lock || return
add-zsh-hook precmd _zac_runtime_due_hook
