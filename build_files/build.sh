#!/bin/bash

set -ouex pipefail

### 1. Enable the active lionheartp Hyprland COPR
dnf5 -y copr enable lionheartp/Hyprland

### 2. Install the absolute bare minimum
# sddm: So you can actually log in
# noctalia-hyprland-meta: The entire Wayland/Hyprland core ecosystem
# kitty: Your lifeline to install Nix tomorrow
RUN dnf5 install -y \
    # Session & Portals (Missing in screenshot)
    sddm \
    uwsm \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    \
    # The Core + Explicitly forcing the missing daemons
    noctalia-hyprland-meta \
    hyprpolkitagent \
    hyprpaper \
    hyprland-plugins \
    hyprland-contrib \
    hyprsysteminfo \
    hyprsunset \
    hyprshot \
    hyprwire \
    hyprlauncher \
    \
    # Clipboard & Screenshots
    cliphist \
    wl-clipboard \
    grim \
    slurp \
    satty \
    \
    # Theming & GUI Fixes
    nwg-look \
    qt6ct \
    waypaper \
    \
    # File Management & System UI
    nautilus \
    gvfs-mtp \
    udiskie \
    network-manager-applet \
    blueman \
    pavucontrol \
    brightnessctl \
    playerctl \
    \
    # Auth & Secrets 
    gnome-keyring \
    libsecret \
    \
    # Display Utilities
    wlr-randr \
    kanshi \
    \
    # Fonts
    jetbrains-mono-fonts \
    fontawesome5-fonts \
    google-noto-fonts-all \
    \
    # CLI Power Tools
    yazi \
    jq \
    socat \
    unzip  \
### 3. Disable the COPR
dnf5 -y copr disable lionheartp/Hyprland

### 4. Enable SDDM
systemctl enable sddm.service
