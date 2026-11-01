#!/bin/bash 
set -euo pipefail

# Custom packages 
REPO_PKGS=(flatpak omarchy-fish)
AUR_PKGS=(visual-studio-code-bin brave-origin-beta-bin voxtype-bin)

# Sync package databases first
echo "==> Syncing package databases"
omarchy update -y

# Install Arch's official repo packages
echo "==> Installing repo packages: ${REPO_PKGS[*]}"
omarchy pkg add "${REPO_PKGS[@]}"

# Install AUR packages
echo "==> Installing AUR packages: ${AUR_PKGS[*]}"
omarchy pkg aur add "${AUR_PKGS[@]}"

# Add Flathub remote
if ! flatpak remotes | grep -q flathub; then
  echo "==> Adding Flathub remote"
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Voxtype: download model + start daemon, so the DEL keybinding works
echo "==> Setting up voxtype"
if [[ -n "$(command -v voxtype)" ]]; then
  voxtype setup --download --model base.en
  omarchy pkg add wtype
  systemctl --user enable --now voxtype.service
fi

echo "==> Install & set Ghostty as default"
omarchy install terminal ghostty

echo "==> Set Fish as default"
if [[ "$SHELL" != "/usr/bin/fish" ]]; then
  echo "==> Switching default shell to fish"
  sudo chsh -s /usr/bin/fish "$USER"
fi

echo "==> Set Brave Origin as default"
BRAVE_DESKTOP="brave-origin-beta.desktop"
if [[ -f "/usr/share/applications/$BRAVE_DESKTOP" ]]; then
    xdg-settings set default-web-browser "$BRAVE_DESKTOP" || true
    xdg-mime default "$BRAVE_DESKTOP" x-scheme-handler/http || true
    xdg-mime default "$BRAVE_DESKTOP" x-scheme-handler/https || true
fi

echo "==> Set imv-dir as default image viewer"
IMV_DESKTOP="/usr/share/applications/imv-dir.desktop"
if [[ -f "$IMV_DESKTOP" ]]; then
    MIMES=$(grep -oP '(?<=^MimeType=).*' "$IMV_DESKTOP" | tr ';' ' ')
    for mime in $MIMES; do
        xdg-mime default imv-dir.desktop "$mime" || true
    done
fi

echo "==> Done. All personal packages installed."
echo "Log out and back in (or start a new session)."
