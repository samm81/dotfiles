#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

iwd_wifi() {
  readarray -t wifi < <(iwctl station wlp9s0 show | awk '{ if($1=="State") { print $2 } if($1=="Connected") { print $3 }}')
  status="${wifi[0]}"
  network="${wifi[1]:-}"
  [ -n "$network" ] && echo "$network" || echo "$status"
}

mem_info=$(free -h | grep 'Mem:' | tr -s ' ' | tr -d 'i')
mem_used=$(echo "$mem_info" | cut -d ' ' -f 3)
mem_total=$(echo "$mem_info" | cut -d ' ' -f 2)
mem=$(echo "${mem_used}")
uptime=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)
linux_version=$(uname -r)
battery_status=$(cat /sys/class/power_supply/BAT0/status)
battery_percent=$(( $(cat /sys/class/power_supply/BAT0/energy_now) * 100 / $(cat /sys/class/power_supply/BAT0/energy_full) ))
battery="${battery_percent} ${battery_status}"
date_formatted=$(date '+%a %F %l:%M:%S %p')
volume=$(pamixer --get-volume-human)
wifi=$(iwd_wifi)

echo "$wifi 📶 $volume 🔊 $mem 💾 $uptime 🆙 $linux_version 🐧 $battery 🔋 $date_formatted"
