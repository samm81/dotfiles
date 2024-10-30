foot_config="$HOME/.config/foot/foot.ini"
if [[ -e "$foot_config" ]]; then
  foot_bgcolor="$(grep '^background' "$foot_config" | cut -d ' ' -f 3)"
  export SIXEL_BGCOLOR="#${foot_bgcolor}"
fi

isinstalled 'nix-shell' && alias nix-shell='TERM=xterm nix-shell'
isinstalled 'tmate' && alias tmate='TERM=xterm tmate'
isinstalled 'ssh' && alias ssh='TERM=xterm-256color ssh'
isinstalled 'emacs' && alias emacs='TERM=xterm-256color emacs'
