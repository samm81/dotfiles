# set environment variables if user's agent already exists
[ -z "$SSH_AUTH_SOCK" ] &&
  SSH_AUTH_SOCK="$(find /tmp -type s -user "$(whoami)" -iwholename '/tmp/ssh-*/agent.*')"
[ -z "$SSH_AGENT_PID" ] &&
  [ -z "$(echo "$SSH_AUTH_SOCK" | cut -d '.' -f 2)" ] &&
  SSH_AGENT_PID=$(($(echo "$SSH_AUTH_SOCK" | cut -d. -f2) + 1))
[ -n "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK
[ -n "$SSH_AGENT_PID" ] && export SSH_AGENT_PID

# start agent if necessary
if [ -z "$SSH_AUTH_SOCK" ] && [ -z "$SSH_TTY" ]; then # if no agent & not in ssh
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add
fi

# setup addition of keys when needed
if isinstalled 'ssh-add'; then
  if [ -z "$SSH_TTY" ]; then       # if not using ssh
    if ssh-add -l >/dev/null; then # check for keys
      alias ssh='ssh-add -l > /dev/null || ssh-add && unalias ssh ; ssh'
      if [ -f '/usr/lib/ssh/x11-ssh-askpass' ]; then
        SSH_ASKPASS='/usr/lib/ssh/x11-ssh-askpass'
        export SSH_ASKPASS
      fi
    fi
  fi
fi
