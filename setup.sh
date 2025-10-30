#!/usr/bin/env bash

# welcome to dvh's awesome thinkpad configuration :)
# late 2025 edition

# core assumptions

# - archinstall successfully completed
# - must be setup with: ext4 main partition, sway desktop profile (polkit), ly greeter, pipewire

# this will setup a base system that has everything needed to get started!
# sets up all the firmware, installs sway and several other useful tools!
# *it installs: sway, swaybg, swayidle, wmenu, brightnessctl, grim, slurp, foot, pavucontrol and xwayland
# it sets up our network using iwd which is the best modern way to manage networks.

# installation

# run
# wget -qO- https://raw.githubusercontent.com/vinnyhorgan/dvhtp/refs/heads/main/setup.sh | bash

# remember to setup git as well.

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

# remove some packages included in the default installation
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
# yay -S --needed --noconfirm zen-browser-bin

# test helium...
# for the browser some more testing is required
# to have a good experience browsing for now i had to integrate the noto-fonts and noto-fonts-emoji packages
# also tweak the helium settings as needed
# install a few more extensions and themes, such as dark reader, material icons, sponsorblock, return dislike.
# also install bitwarden, as helium has no built-in password manager
# one other thing: set the download folder to "downloads", for style choice but also to show the cool icon
yay -S --needed --noconfirm helium-browser-bin

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

# notification helper
yay -S --needed --noconfirm libnotify

# utils
yay -S --needed --noconfirm eza
yay -S --needed --noconfirm bat
yay -S --needed --noconfirm btop
yay -S --needed --noconfirm fastfetch
yay -S --needed --noconfirm lazygit

# for some reason this is not installed by default, but is needed by many tools
yay -S --needed --noconfirm less

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

# starship
log "configuring starship prompt..."

cat > "$HOME/.dvhtp/starship.toml" <<'EOF'
"$schema" = "https://starship.rs/config-schema.json"

format = """
[](color_orange)\
$os\
$username\
[](bg:color_yellow fg:color_orange)\
$directory\
[](fg:color_yellow bg:color_aqua)\
$git_branch\
$git_status\
[](fg:color_aqua bg:color_blue)\
$c\
$cpp\
$rust\
$golang\
$nodejs\
$java\
$python\
[](fg:color_blue bg:color_bg1)\
$time\
[ ](fg:color_bg1)\
$line_break$character"""

palette = "gruvbox_dark"

[palettes.gruvbox_dark]
color_fg0 = "#fbf1c7"
color_bg1 = "#3c3836"
color_bg3 = "#665c54"
color_blue = "#458588"
color_aqua = "#689d6a"
color_green = "#98971a"
color_orange = "#d65d0e"
color_purple = "#b16286"
color_red = "#cc241d"
color_yellow = "#d79921"

[os]
disabled = false
style = "bg:color_orange fg:color_fg0"

[os.symbols]
Arch = "󰣇"

[username]
show_always = true
style_user = "bg:color_orange fg:color_fg0"
style_root = "bg:color_orange fg:color_fg0"
format = "[ $user ]($style)"

[directory]
style = "fg:color_fg0 bg:color_yellow"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"documents" = "󰈙 "
"downloads" = " "
"pictures" = " "
"dev" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:color_aqua"
format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)"

[git_status]
style = "bg:color_aqua"
format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)"

[nodejs]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[c]
symbol = " "
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[cpp]
symbol = " "
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[rust]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[golang]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[java]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[python]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[time]
disabled = false
time_format = "%R"
style = "bg:color_bg1"
format = "[[   $time ](fg:color_fg0 bg:color_bg1)]($style)"

[line_break]
disabled = false

[character]
disabled = false
success_symbol = "[](bold fg:color_green)"
error_symbol = "[](bold fg:color_red)"
vimcmd_symbol = "[](bold fg:color_green)"
vimcmd_replace_one_symbol = "[](bold fg:color_purple)"
vimcmd_replace_symbol = "[](bold fg:color_purple)"
vimcmd_visual_symbol = "[](bold fg:color_yellow)"
EOF

ln -sfn "$HOME/.dvhtp/starship.toml" "$HOME/.config/starship.toml"

# sway
log "configuring sway..."

cat > "$HOME/.dvhtp/sway" <<'EOF'
set $mod Mod4

set $left h
set $down j
set $up k
set $right l

set $term footclient
set $menu wmenu-run -f "JetBrainsMono Nerd Font 17" -i -p "run -> "

font pango:JetBrainsMono Nerd Font 14

seat seat0 xcursor_theme Bibata-Modern-Classic 28

input * xkb_options caps:swapescape

smart_gaps on
gaps inner 8
gaps outer 8

default_border pixel 2

exec mako
exec foot --server

output * bg ~/pictures/bg.png fill

input type:touchpad {
  dwt enabled
  tap enabled
  natural_scroll enabled
}

input type:keyboard {
  # currently assumes it keyboard, to fix :(
  xkb_layout "it"
}

bindsym $mod+Return exec $term
bindsym $mod+w kill
bindsym $mod+space exec $menu

floating_modifier $mod normal

bindsym $mod+Shift+c reload

bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

bindsym $mod+$left focus left
bindsym $mod+$down focus down
bindsym $mod+$up focus up
bindsym $mod+$right focus right

bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

bindsym $mod+Shift+$left move left
bindsym $mod+Shift+$down move down
bindsym $mod+Shift+$up move up
bindsym $mod+Shift+$right move right

bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9
bindsym $mod+0 workspace number 10

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9
bindsym $mod+Shift+0 move container to workspace number 10

bindsym $mod+b splith
bindsym $mod+v splitv

bindsym $mod+s layout stacking
bindsym $mod+e layout toggle split

bindsym $mod+f fullscreen

bindsym $mod+Shift+space floating toggle

#bindsym $mod+space focus mode_toggle

bindsym $mod+a focus parent

bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show

mode "resize" {
  bindsym $left resize shrink width 10px
  bindsym $down resize grow height 10px
  bindsym $up resize shrink height 10px
  bindsym $right resize grow width 10px

  # Ditto, with arrow keys
  bindsym Left resize shrink width 10px
  bindsym Down resize grow height 10px
  bindsym Up resize shrink height 10px
  bindsym Right resize grow width 10px

  # Return to default mode
  bindsym Return mode "default"
  bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# Special keys to adjust volume via PulseAudio
bindsym --locked XF86AudioMute exec pactl set-sink-mute \@DEFAULT_SINK@ toggle
bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume \@DEFAULT_SINK@ -5%
bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume \@DEFAULT_SINK@ +5%
bindsym --locked XF86AudioMicMute exec pactl set-source-mute \@DEFAULT_SOURCE@ toggle
# Special keys to adjust brightness via brightnessctl
bindsym --locked XF86MonBrightnessDown exec brightnessctl set 5%-
bindsym --locked XF86MonBrightnessUp exec brightnessctl set 5%+
# Special key to take a screenshot with grim
bindsym Print exec grim

bar {
  position top

  status_command while date +'%d-%m-%Y %H:%M'; do sleep 60; done

  colors {
    statusline #ffffff
    background #323232
    inactive_workspace #32323200 #32323200 #5c5c5c
  }
}

include /etc/sway/config.d/*
EOF

mkdir -p "$HOME/.config/sway"
ln -sfn "$HOME/.dvhtp/sway" "$HOME/.config/sway/config"

# helix editor

cat > "$HOME/.dvhtp/helix.toml" <<'EOF'
theme = "gruvbox"

[editor]
mouse = false
middle-click-paste = false
line-number = "relative"
cursorline = false
bufferline = "multiple"
color-modes = true
trim-trailing-whitespace = true

[editor.statusline]
mode.normal = "NORMAL"
mode.insert = "INSERT"
mode.select = "SELECT"

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[keys.insert]
up = "no_op"
down = "no_op"
left = "no_op"
right = "no_op"

[keys.normal]
up = "no_op"
down = "no_op"
left = "no_op"
right = "no_op"
EOF

mkdir -p "$HOME/.config/helix"
ln -sfn "$HOME/.dvhtp/helix.toml" "$HOME/.config/helix/config.toml"

# wallpaper
log "fetching wallpaper…"

wp_url="https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox_minimal_space.png"
wp_dir="$HOME/pictures"
wp_file="$wp_dir/bg.png"

mkdir -p "$wp_dir"
wget -qO "$wp_file" "$wp_url"

log "wallpaper saved to $wp_file"

log "all done. reboot and enjoy :)"
