#!/usr/bin/env bash
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx is required but not found on PATH." >&2
  exit 1
fi

codex_home="${CODEX_HOME:-$HOME/.codex}"
session_default="${PLAYWRIGHT_CLI_SESSION:-chad}"
profile_default="${PLAYWRIGHT_CHAD_PROFILE:-$codex_home/playwright/profiles/chad}"

has_session_flag="false"
has_profile_flag="false"
has_persistent_flag="false"
has_help_flag="false"
for arg in "$@"; do
  case "$arg" in
    --session|--session=*)
      has_session_flag="true"
      ;;
    --profile|--profile=*)
      has_profile_flag="true"
      ;;
    --persistent)
      has_persistent_flag="true"
      ;;
    --help|-h)
      has_help_flag="true"
      ;;
  esac
done

command_name=""
skip_next="false"
for arg in "$@"; do
  if [[ "${skip_next}" == "true" ]]; then
    skip_next="false"
    continue
  fi

  case "$arg" in
    --session|--config|--browser|--profile)
      skip_next="true"
      continue
      ;;
    --session=*|--config=*|--browser=*|--profile=*|--*)
      continue
      ;;
  esac

  command_name="$arg"
  break
done

cmd=(npx --yes --package @playwright/cli playwright-cli)
if [[ "${has_session_flag}" != "true" && -n "${session_default}" ]]; then
  cmd+=(--session "${session_default}")
fi
cmd+=("$@")

if [[ "${command_name}" == "open" && "${has_help_flag}" != "true" ]]; then
  if [[ "${has_persistent_flag}" != "true" ]]; then
    cmd+=(--persistent)
  fi

  if [[ "${has_profile_flag}" != "true" ]]; then
    mkdir -p "${profile_default}"
    chmod 700 "${profile_default}" 2>/dev/null || true
    cmd+=(--profile "${profile_default}")
  fi
fi

exec "${cmd[@]}"
