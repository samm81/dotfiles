cargo_bin="${HOME}/.cargo/bin"
if [ -d "$cargo_bin" ]; then
  PATH="$PATH:$cargo_bin"
fi
