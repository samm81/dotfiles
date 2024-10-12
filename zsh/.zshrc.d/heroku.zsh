# heroku autocomplete
# shellcheck disable=SC1090
isinstalled 'heroku' &&
  HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH="$HOME/.cache/heroku/autocomplete/zsh_setup" &&
  [ -f "$HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH" ] &&
  source "$HEROKU_AUTOCOMPLETE_ZSH_SETUP_PATH"
