if command -v 'uv' >/dev/null; then
  export UV_NO_MANAGED_PYTHON='true'
  export UV_PYTHON_DOWNLOADS='never'
fi
