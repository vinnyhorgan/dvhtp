#!/usr/bin/env bash

# welcome to dvh's awesome thinkpad configuration :)
# late 2025 edition

# core assumptions (further development might help remove some)

# - target is a laptop
# - archinstall successfully completed
#   - must be setup with: ext4 main partition, sway desktop profile (polkit), ly greeter, pipewire
# - no other command has been run yet

# installation

# run
# wget -qO- https://raw.githubusercontent.com/vinnyhorgan/dvhtp/refs/heads/main/setup.sh | bash

# enjoy :)

set -euo pipefail

log() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }

log "welcome to dvh's awesome thinkpad configuration :)"
