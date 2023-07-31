#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

mem_info=$(free -h | grep 'Mem:' | tr -s ' ' | tr -d 'i')
mem_used=$(echo "$mem_info" | cut -d ' ' -f 3)
mem_total=$(echo "$mem_info" | cut -d ' ' -f 2)
mem="${mem_used}"
uptime=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)
linux_version=$(uname -r)
battery_status=$(cat /sys/class/power_supply/BAT0/status)
battery_percent=$(( $(cat /sys/class/power_supply/BAT0/energy_now) * 100 / $(cat /sys/class/power_supply/BAT0/energy_full) ))
battery="${battery_percent} ${battery_status}"
date_formatted=$(date '+%a %F %H:%M:%S')
volume=$(pamixer --get-volume-human || echo "[err]")
brightness="$(printf "%.${2:-0}f" "$(brillo -G)")"
wifi=$(wifi-name-iwd)
storage=$(df -h | grep 'crypt' | (while read -r line; do echo "$line" | tr -s ' ' | cut -d ' ' -f 6,5 | awk '{printf " " $2 " " $1 " 🗄"}'; done))

echo "${storage} $wifi 📶 $volume 🔊 $brightness 🔆 $mem 💾 $uptime 🆙 $linux_version 🐧 $battery 🔋 $date_formatted"
