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

echo "$storages $wifi 📶 $volume 🔊 $brightness 🔆 $mem 💾 $uptime 🆙 $linux_version 🐧 $battery 🔋 $date_formatted"
