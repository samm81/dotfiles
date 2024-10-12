FLATPAK_SYSTEM_BINS="/var/lib/flatpak/exports/share"
FLATPAK_USER_BINS="$HOME/.local/share/flatpak/exports/share"
# look fot `flatpak`s last
export PATH="${PATH}:${FLATPAK_USER_BINS}:${FLATPAK_SYSTEM_BINS}"
