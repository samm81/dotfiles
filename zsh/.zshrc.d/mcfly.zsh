if isinstalled 'mcfly'; then
  export MCFLY_KEY_SCHEME='vim'
  export MCFLY_FUZZY=3
  export MCFLY_INTERFACE_VIEW='BOTTOM'
  export MCFLY_DISABLE_MENU='TRUE'
  export MCFLY_RESULTS=60
  eval "$(mcfly init zsh)"
fi
