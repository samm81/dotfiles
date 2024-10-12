asdf_direnv_zsh_config="${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
if [[ ! -e "$asdf_direnv_zsh_config" ]]; then
  asdf_direnv_plugin_dir="${ASDF_DIR:-$HOME/.asdf}/plugins/direnv"
  if [[ -d "$asdf_direnv_plugin_dir" ]]; then
    echo '[direnv] ⚠️ `asdf` has `direnv` plugin, but it has not been setup'
    echo '[direnv] run `asdf direnv setup --shell zsh --version latest`'
    echo '[direnv] then remove the line it adds to `~/.zshrc`'
    echo
  fi
else
  source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

  # https://github.com/direnv/direnv/wiki/Python#zsh
  setopt PROMPT_SUBST

  show_virtual_env() {
    if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
      echo "($(basename "$VIRTUAL_ENV"))"
    fi
  }
  PS1='$(show_virtual_env)'$PS1
fi
