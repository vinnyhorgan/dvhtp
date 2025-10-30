#!/usr/bin/env bash

# welcome to dvh's awesome thinkpad configuration :)
# late 2025 edition

# core assumptions

# - archinstall successfully completed
# - must be setup with: ext4 main partition, sway desktop profile (polkit), ly greeter, pipewire

# installation

# run
# wget -qO- https://raw.githubusercontent.com/vinnyhorgan/dvhtp/refs/heads/main/setup.sh | bash

# enjoy :)

set -euo pipefail

log() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }

log "welcome to dvh's awesome thinkpad configuration :)"

# setup yay

if ! command -v yay &>/dev/null; then
  log "installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
else
  log "yay is already installed."
fi

# remove some packages
yay -Rns --noconfirm swaylock 2>/dev/null || true
yay -Rns --noconfirm waybar 2>/dev/null || true
yay -Rns --noconfirm nano 2>/dev/null || true
yay -Rns --noconfirm vim 2>/dev/null || true
yay -Rns --noconfirm htop 2>/dev/null || true

# setup tlp
if ls /sys/class/power_supply/ | grep -q BAT; then
  log "laptop device detected."

  if ! command -v tlp &>/dev/null; then
    log "installing tlp..."
    yay -S --needed --noconfirm tlp
    sudo systemctl enable tlp.service
  else
    log "tlp is already installed."
  fi
else
  log "desktop device detected."
fi

# setup font
yay -S --needed --noconfirm ttf-jetbrains-mono-nerd

# setup cursor
yay -S --needed --noconfirm bibata-cursor-theme-bin

# main programs :)

# zen, best browser (activate sync for better setup experience)
yay -S --needed --noconfirm zen-browser-bin

# notification daemon
yay -S --needed --noconfirm mako

# best shell
yay -S --needed --noconfirm fish

# best editor
yay -S --needed --noconfirm helix

# best prompt
yay -S --needed --noconfirm starship

# night mode
yay -S --needed --noconfirm gammastep

# foot
log "configuring foot terminal..."

mkdir -p "$HOME/.dvhtp"

cat > "$HOME/.dvhtp/foot.ini" <<'EOF'
include=/usr/share/foot/themes/gruvbox-dark
shell=/usr/bin/fish
font=JetBrainsMono Nerd Font:size=14
pad=8x8

[cursor]
style=beam
blink=yes

[mouse]
hide-when-typing=yes

[colors]
alpha=0.9
alpha-mode=matching
EOF

mkdir -p "$HOME/.config/foot"

ln -sfn "$HOME/.dvhtp/foot.ini" "$HOME/.config/foot/foot.ini"

log "all done. enjoy :)"
