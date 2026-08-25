#!/bin/bash
set -euo pipefail

# Move into this script's own folder, so it works no matter where you run it from
cd "$(dirname "$0")"

./install-packages.sh
./install-dotfiles.sh

# Prompt for reboot, defaulting to Yes, Yep or Yup on Enter
read -r -p "Reboot now? [Y/n] " prompt
if [[ -z "$prompt" || "$prompt" =~ ^[Yy] ]]; then
    sudo reboot
else
    echo "Reboot skipped."
fi
