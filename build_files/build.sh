#!/bin/bash

set -ouex pipefail

### 1. Enable the active lionheartp Hyprland COPR
dnf5 -y copr enable lionheartp/Hyprland

### 2. Install the absolute bare minimum
# sddm: So you can actually log in
# noctalia-hyprland-meta: The entire Wayland/Hyprland core ecosystem
# kitty: Your lifeline to install Nix tomorrow
dnf5 install -y \
    sddm \
    noctalia-hyprland-meta \

### 3. Disable the COPR
dnf5 -y copr disable lionheartp/Hyprland

### 4. Enable SDDM
systemctl enable sddm.service
