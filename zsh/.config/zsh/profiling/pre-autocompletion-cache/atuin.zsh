isinstalled 'atuin' \
  && eval "$(atuin init zsh)" \
  && source <(atuin gen-completions --shell zsh)
