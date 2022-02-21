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

echo "$volume 🔊 $mem" 💾 "$uptime" 🆙 "$linux_version" 🐧 "$battery" 🔋 "$date_formatted"
