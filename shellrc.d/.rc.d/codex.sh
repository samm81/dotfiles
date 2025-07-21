codex() {
  if ! isinstalled 'codex'; then
    echo '`codex` is not installed. probably need to `npm install @openai/codex`.'
    return 1
  fi

  env-openai-api-key codex "$@"
  return "$?"
}
