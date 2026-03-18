if isinstalled 'asdf'; then
  asdf_rust_path="$(asdf where rust 2>/dev/null)"
  [ -r "$asdf_rust_path/env" ] && . "$asdf_rust_path/env"
fi
