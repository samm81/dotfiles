ASDF_NODEJS_GLOBAL_VERSION=$(grep 'nodejs' "${HOME}/.tool-versions" | cut -d ' ' -f 2)
alias vim='ASDF_NODEJS_VERSION="$ASDF_NODEJS_GLOBAL_VERSION" vim'
