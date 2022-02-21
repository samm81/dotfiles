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

theme_path=$(find "${FOOT_THEMES_DIR}/" | shuf | head -n 1)
theme=${theme_path##*/}
theme_file="${FOOT_THEMES_DIR}/${theme}"

cat "${FOOT_CONFIG_DEF_FILE}" <(echo) "${theme_file}" > "${FOOT_CONFIG_FILE}"
