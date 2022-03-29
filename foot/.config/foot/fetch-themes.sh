#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

git init --quiet
git sparse-checkout set themes
git remote add origin https://codeberg.org/dnkl/foot.git
git pull origin master --depth 1
