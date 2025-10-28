#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

mem_info=$(free -h | grep 'Mem:' | tr -s ' ' | tr -d 'i')
mem_used=$(echo "$mem_info" | cut -d ' ' -f 3)
_mem_total=$(echo "$mem_info" | cut -d ' ' -f 2)
mem="${mem_used}"
uptime=$(uptime | cut -d ',' -f1 | cut -d ' ' -f4,5)
linux_version=$(uname -r)

device='/org/freedesktop/UPower/devices/DisplayDevice'
battery_status="$(upower -i "$device" | awk -F': +' '/state/ {print $2}')"
battery_percent="$(upower -i "$device" | awk -F': +' '/percentage/ {print $2}')"
battery="${battery_percent} ${battery_status}"
battery_tte="$(upower -i "$device" | awk -F': +' '/time to empty/ {print $2}')"
if [[ -n "$battery_tte" ]]; then
  battery="${battery} ${battery_tte}"
fi

date_formatted=$(date '+%a %F %H:%M:%S')
volume=$(pamixer --get-volume-human || echo '[err missing `pamixer`]')
brightness="$(brillo -G | xargs --no-run-if-empty printf '%.0f' || echo '[err missing `brillo`]')"
wifi=$(nmcli --terse --fields NAME,TYPE connection show --active | awk -F':' '$2 != "bridge" && $2 != "loopback" {print $1}')
if [[ -z "$wifi" ]]; then
  wifi="disconnected"
fi
storages=$(df -h | grep 'crypt' | (while read -r line; do echo "$line" | tr -s ' ' | cut -d ' ' -f 6,5 | awk '{printf " " $2 " " $1 " 🗄"}'; done))

# === Multi-job aggregator for swaybar ===
# https://chatgpt.com/share/68b3b055-3e34-8002-ae25-263615b0dc7a

state_dir="${XDG_RUNTIME_DIR:-/tmp}/swaybar-pin"
mkdir -p "$state_dir"

STATUS_MAX_SHOW="${STATUS_MAX_SHOW:-5}" # how many badges to render before "+N"

declare -a badges=()
declare -A seen=() # dedupe by label; prefer "running" over "done/failed"

shorten() {
  local s="$1" max="${2:-14}"
  [[ ${#s} -le $max ]] && {
    printf '%s' "$s"
    return
  }
  printf '%s…' "${s:0:max-1}"
}

if [[ -d "$state_dir" ]]; then
  # 1) RUNNING from PID tags (*.pid)
  if compgen -G "$state_dir/"'*.pid' >/dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.pid}"
      [[ -n "${seen[$label]:-}" ]] && continue
      pid="$(awk -F= '/^pid=/{print $2}' "$f" 2>/dev/null | tr -d '[:space:]')"
      if [[ -n "$pid" && -d "/proc/$pid" ]]; then
        saved_cmd="$(awk -F= '/^cmd=/{print substr($0,5)}' "$f" 2>/dev/null || true)"
        now_cmd="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
        if [[ -z "$saved_cmd" || "$saved_cmd" = "$now_cmd" ]]; then
          badges+=("🔧 $(shorten "$label") ⏳")
          seen["$label"]=1
          continue
        fi
      fi
      # PID ended or mismatched → mark done (persists until you delete it)
      date +%s >"${f%.pid}.done"
      rm -f -- "$f"
    done < <(ls -t "$state_dir"/*.pid 2>/dev/null)
  fi

  # 2) RUNNING from wrapper (*.status)
  if compgen -G "$state_dir/"'*.status' >/dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.status}"
      [[ -n "${seen[$label]:-}" ]] && continue
      badges+=("🔧 $(shorten "$label") ⏳")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.status 2>/dev/null)
  fi

  # 3) DONE (.done; use status if present)
  if compgen -G "$state_dir/"'*.done' >/dev/null; then
    while IFS= read -r f; do
      label="${f##*/}"
      label="${label%.done}"
      [[ -n "${seen[$label]:-}" ]] && continue
      # Try to read a "status=" field (from newer writers). If absent, show ⚪.
      status_val="$(awk -F= '/^status=/{print $2}' "$f" 2>/dev/null | tr -d '[:space:]' || true)"
      sym="⚪"
      if [[ -n "$status_val" ]]; then
        if [[ "$status_val" =~ ^[0-9]+$ ]]; then
          if ((status_val == 0)); then
            sym="✅"
          else
            sym="❌"
          fi
        else
          sym="⚪"
        fi
      fi
      badges+=("🔧 $(shorten "$label") ${sym}")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.done 2>/dev/null)
  fi

  # 4) FAILURES ❌ (all .failed; no time limit)
  if compgen -G "$state_dir/"'*.failed' >/dev/null; then
    while IFS= read -r f; do
      read -r ec _ts <"$f" || ec=?
      label="${f##*/}"
      label="${label%.failed}"
      [[ -n "${seen[$label]:-}" ]] && continue
      badges+=("🔧 $(shorten "$label") ❌(${ec})")
      seen["$label"]=1
    done < <(ls -t "$state_dir"/*.failed 2>/dev/null)
  fi
fi

# Build final badge string with overflow indicator
jobs_badge=""
if ((${#badges[@]} > 0)); then
  to_show=("${badges[@]:0:STATUS_MAX_SHOW}")
  overflow=$((${#badges[@]} - ${#to_show[@]}))
  jobs_badge="$(printf '%s ' "${to_show[@]}")"
  jobs_badge="${jobs_badge% }"
  if ((overflow > 0)); then
    jobs_badge="$jobs_badge …+${overflow}"
  fi
fi
# === end multi-job aggregator ===

line="$storages $wifi 📶 $volume 🔊 $brightness 🔆 $mem 💾 $uptime 🆙 $linux_version 🐧 $battery 🔋 $date_formatted"
if [[ -n "$jobs_badge" ]]; then
  echo "$jobs_badge | $line"
else
  echo "$line"
fi
