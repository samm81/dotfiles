#!/usr/bin/env bash
# unnoficial strict mode, note Bash<=4.3 chokes on empty arrays with set -u
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob globstar

FOOT_CONFIG_DIR="${HOME}/.config/foot"
FOOT_CONFIG_FILE="${FOOT_CONFIG_DIR}/foot.ini"
FOOT_CONFIG_DEF_FILE="${FOOT_CONFIG_DIR}/foot.ini.def"
FOOT_THEMES_DIR="${FOOT_CONFIG_DIR}/themes"

[ ! -d "$FOOT_THEMES_DIR" ] \
	&& echo "$FOOT_THEMES_DIR does not exist / is not a directory" \
	&& exit 1

list_themes() {
  ls "$FOOT_THEMES_DIR"
}

set_theme() {
  local theme="${1:?must supply theme name}"
  local theme_file="${FOOT_THEMES_DIR}/${theme}"

  cat "${FOOT_CONFIG_DEF_FILE}" <(echo) "${theme_file}" > "${FOOT_CONFIG_FILE}"
}

random_theme() {
  local theme_path=$(find "${FOOT_THEMES_DIR}/" | shuf | head -n 1)
  local theme=${theme_path##*/}

  echo "$theme"
}

cmd="${1:-}"
case "$cmd" in
  'random') theme="$(random_theme)"; echo "$theme"; set_theme "$theme" ;;
  'list') list_themes ;;
  'set') set_theme "$2" ;;
  *) echo "usage: foot-theme list | random | set THEME" ;;
esac
