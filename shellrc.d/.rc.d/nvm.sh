nvm_dir="$HOME/.nvm"
[ -d "$nvm_dir" ] \
  && export NVM_DIR="$nvm_dir" \
  && [ -s "$NVM_DIR/nvm.sh" ] \
  && \. "$NVM_DIR/nvm.sh"
