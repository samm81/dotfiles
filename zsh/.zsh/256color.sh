check_installed 'nix-shell' && alias nix-shell='export TERM=xterm; nix-shell'
check_installed 'tmat' && alias tmate='TERM="xterm" tmate'
check_installed 'ssh' && alias ssh='export TERM="xterm-256color"; ssh'
check_installed 'emacs' && alias emacs='export TERM="xterm-256color"; emacs'
