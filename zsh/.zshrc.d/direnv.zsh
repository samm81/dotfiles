if isinstalled 'direnv'; then
  eval "$(direnv hook zsh)"

  if isinstalled 'asdf'; then
    direnv() {
      asdf exec direnv "$@"
    }
  fi
fi
