NIX="${HOME}/.nix-profile/etc/profile.d/nix.sh"
# shellcheck disable=SC1090
[[ -f "$NIX" ]] && [[ -r "$NIX" ]] && source "$NIX"
