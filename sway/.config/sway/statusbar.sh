#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

have_cmd() {
  command -v "$1" > /dev/null 2>&1
}

err_missing_cmd() {
  printf '[err missing `%s`]' "$1"
}

err_segment() {
  printf '[err %s]' "$1"
}

trim_leading_whitespace() {
  local s="${1:-}"
  printf '%s' "${s#"${s%%[![:space:]]*}"}"
}

human_iec() {
  have_cmd numfmt || return 1
  numfmt --to=iec -- "${1:-0}" 2> /dev/null
}

human_iec_1dp() {
  have_cmd numfmt || return 1
  numfmt --to=iec --format='%.1f' -- "${1:-0}" 2> /dev/null
}

format_usage_pair() {
  local used_bytes="${1:-0}" total_bytes="${2:-0}"
  local used_human total_human
  if ((total_bytes == 0)); then
    printf 'off'
    return 0
  fi
  if ! used_human=$(human_iec "$used_bytes"); then
    return 1
  fi
  if ! total_human=$(human_iec "$total_bytes"); then
    return 1
  fi
  printf '%s/%s' "$used_human" "$total_human"
}

get_mem() {
  local mem_total_bytes mem_used_bytes mem_total mem_used

  if ! have_cmd free; then
    err_missing_cmd 'free'
    return 0
  fi
  if ! have_cmd numfmt; then
    err_missing_cmd 'numfmt'
    return 0
  fi
  if ! IFS=' ' read -r mem_total_bytes mem_used_bytes < <(free --bytes 2> /dev/null | awk '/^Mem:/ {print $2, $3}'); then
    err_segment 'mem'
    return 0
  fi
  if [[ -z "$mem_total_bytes" || -z "$mem_used_bytes" ]]; then
    err_segment 'mem'
    return 0
  fi
  if ! mem_used=$(human_iec_1dp "$mem_used_bytes"); then
    err_segment 'mem'
    return 0
  fi
  if ! mem_total=$(human_iec_1dp "$mem_total_bytes"); then
    err_segment 'mem'
    return 0
  fi
  printf '%s/%s' "$mem_used" "$mem_total"
}

get_swap() {
  local swap_kib_total=0
  local swap_kib_used=0
  local name size_kib used_kib swap_value

  if ! have_cmd numfmt; then
    err_missing_cmd 'numfmt'
    return 0
  fi
  if [[ ! -r /proc/swaps ]]; then
    err_segment 'swap'
    return 0
  fi
  while IFS=$' \t' read -r name _type size_kib used_kib _priority; do
    [[ "$name" == "Filename" ]] && continue
    [[ "$name" == *zram* ]] && continue
    [[ "$size_kib" =~ ^[0-9]+$ && "$used_kib" =~ ^[0-9]+$ ]] || continue
    swap_kib_total=$((swap_kib_total + size_kib))
    swap_kib_used=$((swap_kib_used + used_kib))
  done < /proc/swaps

  if ! swap_value=$(format_usage_pair "$((swap_kib_used * 1024))" "$((swap_kib_total * 1024))"); then
    err_segment 'swap'
    return 0
  fi
  printf '%s' "$swap_value"
}

get_uptime() {
  local uptime_seconds _fractional

  if ! IFS=' ' read -r uptime_seconds _fractional < /proc/uptime 2> /dev/null; then
    err_segment 'uptime'
    return 0
  fi
  uptime_seconds="${uptime_seconds%.*}"
  if [[ ! "$uptime_seconds" =~ ^[0-9]+$ ]]; then
    err_segment 'uptime'
    return 0
  fi
  printf '%02d:%02d' "$((uptime_seconds / 3600))" "$(((uptime_seconds % 3600) / 60))"
}

get_linux_version() {
  local linux_version

  if ! have_cmd uname; then
    err_missing_cmd 'uname'
    return 0
  fi
  if ! linux_version=$(uname -r 2> /dev/null); then
    err_segment 'linux'
    return 0
  fi
  printf '%s' "$linux_version"
}

get_battery() {
  local device='/org/freedesktop/UPower/devices/DisplayDevice'
  local info line value battery_status="" battery_percent="" battery_eta="" battery

  if ! have_cmd upower; then
    err_missing_cmd 'upower'
    return 0
  fi
  if ! info=$(upower -i "$device" 2> /dev/null); then
    err_segment 'battery'
    return 0
  fi

  while IFS= read -r line; do
    value=$(trim_leading_whitespace "${line#*:}")
    case "$line" in
      *"state:"*)
        battery_status="$value"
        ;;
      *"percentage:"*)
        battery_percent="$value"
        ;;
      *"time to empty:"*)
        battery_eta="$value"
        ;;
      *"time to full:"*)
        if [[ -z "$battery_eta" ]]; then
          battery_eta="$value"
        fi
        ;;
    esac
  done <<< "$info"

  if [[ -z "$battery_status" || -z "$battery_percent" ]]; then
    err_segment 'battery'
    return 0
  fi

  battery="${battery_percent} ${battery_status}"
  if [[ -n "$battery_eta" ]]; then
    battery="${battery} ${battery_eta}"
  fi
  printf '%s' "$battery"
}

get_date_formatted() {
  local date_formatted

  if ! have_cmd datets; then
    err_missing_cmd 'datets'
    return 0
  fi
  if ! date_formatted=$(datets 2> /dev/null); then
    err_segment 'date'
    return 0
  fi
  printf '%s' "$date_formatted"
}

get_volume() {
  local volume

  if ! have_cmd pamixer; then
    err_missing_cmd 'pamixer'
    return 0
  fi
  if ! volume=$(pamixer --get-volume-human 2> /dev/null); then
    err_segment 'volume'
    return 0
  fi
  printf '%s' "$volume"
}

get_brightness() {
  local brightness_raw brightness

  if ! have_cmd brillo; then
    err_missing_cmd 'brillo'
    return 0
  fi
  if ! brightness_raw=$(brillo -G 2> /dev/null); then
    err_segment 'brightness'
    return 0
  fi
  if ! brightness=$(printf '%.0f' "$brightness_raw" 2> /dev/null); then
    err_segment 'brightness'
    return 0
  fi
  printf '%s' "$brightness"
}

get_wifi() {
  local active_connections name type wifi=""

  if ! have_cmd nmcli; then
    err_missing_cmd 'nmcli'
    return 0
  fi
  if ! active_connections=$(nmcli --terse --fields NAME,TYPE connection show --active 2> /dev/null); then
    err_segment 'wifi'
    return 0
  fi

  while IFS=: read -r name type; do
    [[ -n "$name" ]] || continue
    if [[ "$type" != "bridge" && "$type" != "loopback" ]]; then
      wifi="$name"
      break
    fi
  done <<< "$active_connections"

  if [[ -z "$wifi" ]]; then
    printf 'disconnected'
    return 0
  fi
  printf '%s' "$wifi"
}

get_storages() {
  local df_output filesystem usepct mountpoint storages=""

  if ! have_cmd df; then
    printf '🗄 %s ' "$(err_missing_cmd 'df')"
    return 0
  fi
  if ! df_output=$(df -h 2> /dev/null); then
    printf '🗄 %s ' "$(err_segment 'storage')"
    return 0
  fi

  while IFS=$' \t' read -r filesystem _ _ _ usepct mountpoint _; do
    [[ "$filesystem" == "Filesystem" ]] && continue
    [[ "$filesystem" == *crypt* ]] || continue
    [[ -n "$usepct" && -n "$mountpoint" ]] || continue
    storages+="🗄 ${usepct} ${mountpoint} "
  done <<< "$df_output"

  printf '%s' "$storages"
}

if ! mem=$(get_mem); then
  mem='[err mem]'
fi
if ! swap=$(get_swap); then
  swap='[err swap]'
fi
if ! uptime=$(get_uptime); then
  uptime='[err uptime]'
fi
if ! linux_version=$(get_linux_version); then
  linux_version='[err linux]'
fi
if ! battery=$(get_battery); then
  battery='[err battery]'
fi
if ! date_formatted=$(get_date_formatted); then
  date_formatted='[err date]'
fi
if ! volume=$(get_volume); then
  volume='[err volume]'
fi
if ! brightness=$(get_brightness); then
  brightness='[err brightness]'
fi
if ! wifi=$(get_wifi); then
  wifi='[err wifi]'
fi
if ! storages=$(get_storages); then
  storages='🗄 [err storage] '
fi

# === Multi-job aggregator for swaybar ===
# https://chatgpt.com/share/68b3b055-3e34-8002-ae25-263615b0dc7a

STATUS_MAX_SHOW="${STATUS_MAX_SHOW:-5}" # how many badges to render before "+N"

shorten() {
  local s="$1" max="${2:-14}"
  [[ ${#s} -le $max ]] && {
    printf '%s' "$s"
    return
  }
  printf '%s…' "${s:0:max-1}"
}

build_jobs_badge() {
  local state_dir="${XDG_RUNTIME_DIR:-/tmp}/swaybar-pin"
  local status_max_show="${STATUS_MAX_SHOW:-5}"
  local label pid saved_cmd now_cmd status_val sym ec jobs_badge="" overflow
  local -a badges=() to_show=()
  local -A seen=()

  if [[ ! "$status_max_show" =~ ^[0-9]+$ ]]; then
    status_max_show=5
  fi
  if ! mkdir -p "$state_dir" 2> /dev/null; then
    printf '🔧 [err jobs]'
    return 0
  fi

  # 1) RUNNING from PID tags (*.pid)
  if compgen -G "$state_dir/"'*.pid' > /dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.pid}"
      [[ -n "${seen[$label]:-}" ]] && continue
      pid="$(awk -F= '/^pid=/{print $2}' "$f" 2> /dev/null | tr -d '[:space:]')"
      if [[ -n "$pid" && -d "/proc/$pid" ]]; then
        saved_cmd="$(awk -F= '/^cmd=/{print substr($0,5)}' "$f" 2> /dev/null || true)"
        now_cmd="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2> /dev/null || true)"
        if [[ -z "$saved_cmd" || "$saved_cmd" = "$now_cmd" ]]; then
          badges+=("🔧 $(shorten "$label") ⏳")
          seen["$label"]=1
          continue
        fi
      fi
      date +%s > "${f%.pid}.done"
      rm -f -- "$f"
    done < <(ls -t "$state_dir"/*.pid 2> /dev/null)
  fi

  # 2) RUNNING from wrapper (*.status)
  if compgen -G "$state_dir/"'*.status' > /dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.status}"
      [[ -n "${seen[$label]:-}" ]] && continue
      badges+=("🔧 $(shorten "$label") ⏳")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.status 2> /dev/null)
  fi

  # 3) DONE (.done; use status if present)
  if compgen -G "$state_dir/"'*.done' > /dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.done}"
      [[ -n "${seen[$label]:-}" ]] && continue
      status_val="$(awk -F= '/^status=/{print $2}' "$f" 2> /dev/null | tr -d '[:space:]' || true)"
      sym="⚪"
      if [[ -n "$status_val" && "$status_val" =~ ^[0-9]+$ ]]; then
        if ((status_val == 0)); then
          sym="✅"
        else
          sym="❌"
        fi
      fi
      badges+=("🔧 $(shorten "$label") ${sym}")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.done 2> /dev/null)
  fi

  # 4) FAILURES ❌ (all .failed; no time limit)
  if compgen -G "$state_dir/"'*.failed' > /dev/null; then
    while IFS= read -r f; do
      read -r ec _ts < "$f" || ec='?'
      label="${f##*/}"
      label="${label%.failed}"
      [[ -n "${seen[$label]:-}" ]] && continue
      badges+=("🔧 $(shorten "$label") ❌(${ec})")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.failed 2> /dev/null)
  fi

  if ((${#badges[@]} > 0)); then
    to_show=("${badges[@]:0:status_max_show}")
    overflow=$((${#badges[@]} - ${#to_show[@]}))
    jobs_badge="$(printf '%s ' "${to_show[@]}")"
    jobs_badge="${jobs_badge% }"
    if ((overflow > 0)); then
      jobs_badge="$jobs_badge …+${overflow}"
    fi
  fi
  printf '%s' "$jobs_badge"
}

if ! jobs_badge=$(build_jobs_badge); then
  jobs_badge='🔧 [err jobs]'
fi
# === end multi-job aggregator ===

line="$storages 📶 $wifi 🔊 $volume 🔆 $brightness 💾 $mem 🔁 $swap 🆙 $uptime 🐧 $linux_version 🔋 $battery 🗓️ $date_formatted"
if [[ -n "$jobs_badge" ]]; then
  echo "$jobs_badge | $line"
else
  echo "$line"
fi
