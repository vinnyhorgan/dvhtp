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

# utils
yay -S --needed --noconfirm eza
yay -S --needed --noconfirm bat
yay -S --needed --noconfirm btop

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

# fish
log "configuring fish shell..."

cat > "$HOME/.dvhtp/config.fish" <<'EOF'
function fish_greeting
end

alias cat="bat --paging=never --style=plain --theme='gruvbox-dark'"
alias ls="eza --group-directories-first --icons"
alias ll="eza -lah --group-directories-first --icons"
alias la="eza -a --group-directories-first --icons"
alias top="btop"

alias c="clear"
alias l="ls"
alias h="helix"
alias ..="cd .."
alias update="yay"
alias install="yay -S"
alias remove="yay -Rns"
alias pls="sudo"

function fish_command_not_found
  echo -n "what the hell is '"
  set_color red
  echo -n $argv
  set_color normal
  echo "' ??"
end

starship init fish | source
EOF

mkdir -p "$HOME/.config/fish"
ln -sfn "$HOME/.dvhtp/config.fish" "$HOME/.config/fish/config.fish"

# wallpaper
log "fetching wallpaper…"

wp_url="https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox_minimal_space.png"
wp_dir="$HOME/pictures"
wp_file="$wp_dir/bg.png"

mkdir -p "$wp_dir"
wget -qO "$wp_file" "$wp_url"

log "wallpaper saved to $wp_file"

log "all done. enjoy :)"
