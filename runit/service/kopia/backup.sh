#!/bin/sh
# unofficial POSIX shell strict mode
set -o errexit
set -o nounset

IFS=$(printf '\n\t')

[ "${TRACE:-0}" = "1" ] && set -o xtrace

cd "$(dirname "$0")"

log() {
  echo "${1:?missing log message}"
}

KOPIA_LOG_DIR="${HOME}/.cache/kopia"
main() {
  log 'starting'
  log "check \$KOPIA_LOG_DIR=\"${KOPIA_LOG_DIR:?missing KOPIA_LOG_DIR}\" for logs"

  if on-mobile-data; then
    log "on mobile data, skipping..."
    exit 1
  fi

  if kopia snapshot create "${HOME}"; then
    log 'success'
  else
    log 'failed'
    exit 1
  fi
}

main "$@"

exit 0
