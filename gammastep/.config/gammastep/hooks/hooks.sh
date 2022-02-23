#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

event="$1"
old_period="$2"
new_period="$3"

case "$event" in
  'period-changed')
    exec 'Gammastep' "Period changed to $new_period"
esac
