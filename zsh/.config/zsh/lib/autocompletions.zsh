zmodload zsh/datetime 2>/dev/null || true

_zac_set_paths() {
  : "${XDG_CONFIG_HOME:=${HOME}/.config}"
  : "${XDG_DATA_HOME:=${HOME}/.local/share}"
  : "${XDG_CACHE_HOME:=${HOME}/.cache}"

  typeset -g ZAC_CONFIG_DIR="${XDG_CONFIG_HOME}/zsh"
  typeset -g ZAC_REGISTRY_DIR="${ZAC_CONFIG_DIR}/autocompletions.d"
  typeset -g ZAC_SITE_FUNCTIONS_DIR="${XDG_DATA_HOME}/zsh/site-functions"
  typeset -g ZAC_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
  typeset -g ZAC_TMP_DIR="${ZAC_CACHE_DIR}/tmp"
  typeset -g ZAC_STAMP_FILE="${ZAC_CACHE_DIR}/autocompletions.stamp"
  typeset -g ZAC_LOG_FILE="${ZAC_CACHE_DIR}/autocompletions.log"
  typeset -g ZAC_LOCK_ROOT="${XDG_RUNTIME_DIR:-${ZAC_CACHE_DIR}}"
  typeset -g ZAC_LOCK_DIR="${ZAC_LOCK_ROOT}/autocompletions.lock"
}

_zac_set_defaults() {
  typeset -g ZAC_DEFAULT_MODE="${ZSH_AUTOCOMPLETIONS_MODE:-prompt}"
  typeset -g ZAC_DEFAULT_DAYS="${ZSH_AUTOCOMPLETIONS_DAYS:-7}"
  typeset -g ZAC_DEFAULT_VERBOSITY="${ZSH_AUTOCOMPLETIONS_VERBOSITY:-1}"
  typeset -g ZAC_LOCK_STALE_SECONDS="${ZSH_AUTOCOMPLETIONS_LOCK_STALE_SECONDS:-21600}"
}

_zac_prepare_lock_root() {
  if command mkdir -p -- "$ZAC_LOCK_ROOT" 2>/dev/null; then
    return 0
  fi

  ZAC_LOCK_ROOT="${ZAC_CACHE_DIR}"
  ZAC_LOCK_DIR="${ZAC_LOCK_ROOT}/autocompletions.lock"
  command mkdir -p -- "$ZAC_LOCK_ROOT"
}

_zac_ensure_dirs() {
  _zac_prepare_lock_root || return 1
  command mkdir -p -- "$ZAC_REGISTRY_DIR" "$ZAC_SITE_FUNCTIONS_DIR" "$ZAC_TMP_DIR"
}

_zac_log() {
  local message="$*"
  local timestamp

  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  [[ -d "$ZAC_CACHE_DIR" ]] && print -r -- "[${timestamp}] ${message}" >> "$ZAC_LOG_FILE"

  if (( ${ZAC_VERBOSITY:-1} > 0 )); then
    print -u2 -r -- "$message"
  fi
}

_zac_lock_age_seconds() {
  zmodload -F zsh/stat b:zstat 2>/dev/null || return 1

  local -a stat_info
  zstat -A stat_info +mtime -- "$ZAC_LOCK_DIR" 2>/dev/null || return 1
  print -r -- $(( EPOCHSECONDS - stat_info[1] ))
}

_zac_release_lock() {
  [[ -d "$ZAC_LOCK_DIR" ]] || return 0

  command rm -f -- "$ZAC_LOCK_DIR/pid" "$ZAC_LOCK_DIR/started_at" 2>/dev/null
  rmdir "$ZAC_LOCK_DIR" 2>/dev/null
}

_zac_clear_stale_lock() {
  local age
  age="$(_zac_lock_age_seconds)" || return 1
  (( age < ZAC_LOCK_STALE_SECONDS )) && return 1

  _zac_log "clearing stale zsh autocompletion lock (${age}s old)"
  _zac_release_lock
}

_zac_acquire_lock() {
  _zac_prepare_lock_root || return 1

  if ! command mkdir -- "$ZAC_LOCK_DIR" 2>/dev/null; then
    _zac_clear_stale_lock || return 1
    command mkdir -- "$ZAC_LOCK_DIR" 2>/dev/null || return 1
  fi

  print -r -- "$$" >| "$ZAC_LOCK_DIR/pid"
  print -r -- "$EPOCHSECONDS" >| "$ZAC_LOCK_DIR/started_at"
}

_zac_load_stamp() {
  typeset -gA _ZAC_STAMP_VERSIONS
  _ZAC_STAMP_VERSIONS=()

  [[ -r "$ZAC_STAMP_FILE" ]] || return 0

  local key value
  local entry_id

  while IFS='=' read -r key value; do
    [[ "$key" =~ '^[A-Z0-9_]+$' ]] || continue

    case "$key" in
      ENTRY_*_VERSION)
        entry_id="${key#ENTRY_}"
        entry_id="${entry_id%_VERSION}"
        eval "_ZAC_STAMP_VERSIONS[$entry_id]=$value"
        ;;
    esac
  done < "$ZAC_STAMP_FILE"
}

_zac_write_stamp() {
  local epoch="${1:-$EPOCHSECONDS}"
  local mode="${2:-$ZAC_DEFAULT_MODE}"
  local tmp_file="${ZAC_TMP_DIR}/stamp.${$}.${RANDOM}.tmp"
  local entry_id

  _zac_ensure_dirs || return 1

  {
    printf 'LAST_EPOCH=%q\n' "$epoch"
    printf 'MODE=%q\n' "$mode"

    for entry_id in ${(ok)_ZAC_STAMP_VERSIONS}; do
      printf '%s=%q\n' "ENTRY_${entry_id}_VERSION" "${_ZAC_STAMP_VERSIONS[$entry_id]}"
    done
  } >| "$tmp_file" || return 1

  command mv -f -- "$tmp_file" "$ZAC_STAMP_FILE"
}

_zac_load_entry() {
  local registry_file="$1"
  local zac_entry_id=''
  local zac_completion_name=''
  local zac_check_command=''
  local zac_version_command=''
  local zac_generate_command=''
  local zac_cleanup_command=''

  # shellcheck disable=SC1090
  source "$registry_file" || return 1

  [[ -n "$zac_entry_id" ]] || return 1
  [[ -n "$zac_completion_name" ]] || return 1
  [[ -n "$zac_check_command" ]] || return 1
  [[ -n "$zac_version_command" ]] || return 1
  [[ -n "$zac_generate_command" ]] || return 1
  [[ "$zac_entry_id" =~ '^[A-Za-z0-9_]+$' ]] || return 1
  [[ "$zac_completion_name" == _* ]] || return 1

  typeset -g _ZAC_ENTRY_ID="$zac_entry_id"
  typeset -g _ZAC_ENTRY_COMPLETION="$zac_completion_name"
  typeset -g _ZAC_ENTRY_CHECK="$zac_check_command"
  typeset -g _ZAC_ENTRY_VERSION="$zac_version_command"
  typeset -g _ZAC_ENTRY_GENERATE="$zac_generate_command"
  typeset -g _ZAC_ENTRY_CLEANUP="$zac_cleanup_command"
}

_zac_capture_output() {
  local command_text="$1"
  local output

  output="$(eval "$command_text")" || return 1
  output="${output%%$'\n'*}"
  output="${output//$'\n'/ }"
  print -r -- "$output"
}

_zac_generate_completion_file() {
  local target_file="${ZAC_SITE_FUNCTIONS_DIR}/${_ZAC_ENTRY_COMPLETION}"
  local tmp_file="${ZAC_TMP_DIR}/${_ZAC_ENTRY_COMPLETION}.${$}.${RANDOM}.tmp"

  if ! eval "$_ZAC_ENTRY_GENERATE" >| "$tmp_file"; then
    command rm -f -- "$tmp_file"
    _zac_log "failed to generate ${_ZAC_ENTRY_ID} completion"
    return 1
  fi

  if [[ ! -s "$tmp_file" ]]; then
    command rm -f -- "$tmp_file"
    _zac_log "generated empty completion for ${_ZAC_ENTRY_ID}"
    return 1
  fi

  command mv -f -- "$tmp_file" "$target_file"
}

_zac_cleanup_missing_entry() {
  local target_file="${ZAC_SITE_FUNCTIONS_DIR}/${_ZAC_ENTRY_COMPLETION}"

  if [[ -n "$_ZAC_ENTRY_CLEANUP" ]]; then
    eval "$_ZAC_ENTRY_CLEANUP" || _zac_log "cleanup failed for ${_ZAC_ENTRY_ID}"
  fi

  if [[ -e "$target_file" ]]; then
    command rm -f -- "$target_file"
    _zac_log "removed stale ${_ZAC_ENTRY_COMPLETION}"
  fi
}

_zac_refresh_entries() {
  local mode="${1:-$ZAC_DEFAULT_MODE}"
  local registry_file
  local current_version
  local previous_version
  local target_file
  local had_errors=0
  local refresh_count=0
  local -a registry_files
  local -A next_versions

  registry_files=("${ZAC_REGISTRY_DIR}"/*(.N))
  next_versions=()

  _zac_load_stamp

  for registry_file in "${registry_files[@]}"; do
    if ! _zac_load_entry "$registry_file"; then
      _zac_log "invalid zsh autocompletion entry: ${registry_file}"
      had_errors=1
      continue
    fi

    target_file="${ZAC_SITE_FUNCTIONS_DIR}/${_ZAC_ENTRY_COMPLETION}"

    if ! eval "$_ZAC_ENTRY_CHECK" >/dev/null 2>&1; then
      _zac_cleanup_missing_entry
      continue
    fi

    current_version="$(_zac_capture_output "$_ZAC_ENTRY_VERSION")" || {
      _zac_log "failed to read version for ${_ZAC_ENTRY_ID}"
      had_errors=1
      continue
    }

    previous_version="${_ZAC_STAMP_VERSIONS[$_ZAC_ENTRY_ID]-}"
    if [[ "$current_version" != "$previous_version" || ! -s "$target_file" ]]; then
      _zac_log "refreshing ${_ZAC_ENTRY_ID} completion"
      _zac_generate_completion_file || {
        had_errors=1
        continue
      }
      (( refresh_count += 1 ))
    fi

    next_versions[$_ZAC_ENTRY_ID]="$current_version"
  done

  (( had_errors == 0 )) || return 1

  _ZAC_STAMP_VERSIONS=()
  _ZAC_STAMP_VERSIONS=("${(@kv)next_versions}")
  _zac_write_stamp "$EPOCHSECONDS" "$mode" || return 1

  if (( refresh_count > 0 )); then
    _zac_log "updated ${refresh_count} zsh completion(s)"
  else
    _zac_log "zsh completions are already current"
  fi
}

zac_refresh_with_lock() {
  local mode="${1:-$ZAC_DEFAULT_MODE}"
  local verbosity="${2:-$ZAC_DEFAULT_VERBOSITY}"

  typeset -g ZAC_VERBOSITY="$verbosity"
  _zac_ensure_dirs || return 1
  _zac_refresh_entries "$mode"
}

zac_touch_stamp() {
  local mode="${1:-$ZAC_DEFAULT_MODE}"
  local verbosity="${2:-$ZAC_DEFAULT_VERBOSITY}"

  typeset -g ZAC_VERBOSITY="$verbosity"
  _zac_ensure_dirs || return 1
  _zac_load_stamp
  _zac_write_stamp "$EPOCHSECONDS" "$mode"
}

zac_refresh_command() {
  local mode="$ZAC_DEFAULT_MODE"
  local verbosity="$ZAC_DEFAULT_VERBOSITY"
  local arg

  while (( $# > 0 )); do
    arg="$1"
    shift

    case "$arg" in
      --help|-h)
        cat <<'EOF'
usage: zrefresh-completions [--mode MODE] [--quiet]

refresh zsh completion files from ~/.config/zsh/autocompletions.d into the
xdg site-functions directory.

options:
  --mode MODE  record the runtime mode in the completion cache stamp.
               prompt      ask before refreshing stale completions (default)
               background  refresh stale completions in the background
               reminder    print a reminder when completions are stale
               disabled    skip stale-completion checks
  --quiet      suppress non-error output
  --help, -h   show this help

note: this command always refreshes immediately. MODE describes what interactive
shells should do later when the cache becomes stale.
EOF
        return 0
        ;;
      --mode)
        (( $# > 0 )) || {
          print -u2 -r -- "zrefresh-completions: missing value for --mode"
          return 1
        }
        mode="$1"
        shift
        ;;
      --quiet)
        verbosity=0
        ;;
      *)
        print -u2 -r -- "zrefresh-completions: unknown argument: ${arg}"
        return 1
        ;;
    esac
  done

  typeset -g ZAC_VERBOSITY="$verbosity"
  _zac_ensure_dirs || return 1

  if ! _zac_acquire_lock; then
    (( verbosity > 0 )) && print -u2 -r -- "zrefresh-completions: another refresh is already in progress"
    return 0
  fi

  zac_refresh_with_lock "$mode" "$verbosity"
  local exit_code=$?
  _zac_release_lock
  return "$exit_code"
}

_zac_set_paths
_zac_set_defaults
