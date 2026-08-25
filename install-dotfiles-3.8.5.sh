#!/bin/bash 

HOME_DIR=$HOME

DOTFILES_REPO_URL="https://github.com/0leodev/dotfiles"
DOTFILES_REPO_NAME="dotfiles"

THEME_DIR="$HOME_DIR/.config/omarchy/themes"
THEME_REPO_URL="https://github.com/0leodev/omarchy-0xleovision-theme.git"
THEME_NAME="0xleovision"

# WAYBAR_ISLAND_DIR="$HOME_DIR/dotfiles/waybar/.config/waybar"
# WAYBAR_ISLAND_REPO_URL="https://github.com/0leodev/omarchy-waybar-island.git"#
# WAYBAR_ISLAND_NAME="waybar-island"

CONFIGS=(fastfetch fish ghostty hypr nvim opencode swayosd uwsm waybar voxtype)

echo "==> Installing stow"
sudo pacman -S --needed --noconfirm stow

# Check if the repository already exists
if [ -d "$HOME_DIR/$DOTFILES_REPO_NAME" ]; then
  echo "Repository '$DOTFILES_REPO_NAME' already exists. Skipping clone"
else
  if ! git clone "$DOTFILES_REPO_URL" "$HOME_DIR/$DOTFILES_REPO_NAME"; then
    echo "Failed to clone the repository."
    exit 1
  fi  
fi

# Remove old configs and stow new ones
if cd "$HOME_DIR/$DOTFILES_REPO_NAME"; then
  echo "removing old configs"
  rm -rf "${CONFIGS[@]/#/$HOME/.config/}" "$HOME_DIR/.config/omarchy/branding" "$HOME_DIR/.config/starship.toml"
  stow "${CONFIGS[@]}"
  stow omarchy
  stow starship
fi 

# Add my personal theme
echo "==> Cloning theme into omarchy themes folder"
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
  echo "Theme $THEME_NAME already exists. Skipping clone"
  omarchy theme set "$THEME_NAME" >/dev/null
else
  mkdir -p "$THEME_DIR"
  if git clone "$THEME_REPO_URL" "$THEME_DIR/$THEME_NAME"; then
    omarchy theme set "$THEME_NAME" >/dev/null
  else  
    echo "Failed to clone theme."
  fi
fi

# # Add waybar island
# echo "==> Cloning waybar island into waybar folder as alternative"
# if [ -d "$WAYBAR_ISLAND_DIR/$WAYBAR_ISLAND_NAME" ]; then
#   echo "$WAYBAR_ISLAND_NAME already exists. Skipping clone"
# else
#   mkdir -p "$WAYBAR_ISLAND_DIR"
#   if ! git clone "$WAYBAR_ISLAND_REPO_URL" "$WAYBAR_ISLAND_DIR/$WAYBAR_ISLAND_NAME"; then  
#     echo "Failed to clone waybar island."
#   fi
# fi

# Recreate nvim's theme.lua link — stow installs the repo's copy verbatim,
# and that copy is stale/broken (trailing newlines in the target)
echo "==> Fixing nvim theme link"
ln -sfn "$HOME_DIR/.config/omarchy/current/theme/neovim.lua" \
  "$HOME_DIR/.config/nvim/lua/plugins/theme.lua"
