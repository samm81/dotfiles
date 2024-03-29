source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

# https://github.com/direnv/direnv/wiki/Python#zsh
setopt PROMPT_SUBST

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
