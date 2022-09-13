#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

IWD_STATION_NAME="wlp9s0"

iwd_wifi() {
  readarray -t wifi < <(iwctl station $IWD_STATION_NAME show | awk '{ if($1=="State") { print $2 } if($1=="Connected") { print substr($0, index($0, $3)) }}')
  status="${wifi[0]:-}"
  network_raw="${wifi[1]:-}"
  network="${network_raw%${network_raw##*[![:space:]]}}"
  echo "${network:-${status:-err}}"
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
date_formatted=$(date '+%a %F %H:%M:%S')
volume=$(pamixer --get-volume-human)
wifi=$(iwd_wifi)

echo "$wifi 📶 $volume 🔊 $mem 💾 $uptime 🆙 $linux_version 🐧 $battery 🔋 $date_formatted"
