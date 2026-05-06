#!/usr/bin/env bash
set -ouex pipefail

# ── 1. Repos ─────────────────────────────────────────────────────────────────

dnf5 install -y dnf5-plugins

dnf5 -y copr enable lionheartp/Hyprland

tee /etc/yum.repos.d/nordvpn.repo << "EOF" > /dev/null
[nordvpn]
name=NordVPN
baseurl=https://repo.nordvpn.com/yum/nordvpn/centos/${basearch}/
gpgkey=https://repo.nordvpn.com/gpg/nordvpn_public.asc
gpgcheck=1
EOF

# ── 2. Kaamos stack ───────────────────────────────────────────────────────────

dnf5 install -y \
    sddm \
    nautilus \
    xdg-desktop-portal-hyprland \
    network-manager-applet \
    noctalia-hyprland-meta \
    hyprpolkitagent \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprcursor \
    cliphist \
    hyprqt6engine \
    hyprland-qt-support \
    qt6ct \
    nwg-look \
    waypaper \
    hyprlauncher \
    hyprshot \
    hyprpicker \
    hyprsunset \
    hyprsysteminfo \
    hyprpwcenter \
    hyprshutdown \
    gpu-screen-recorder \
    kanshi \
    nordvpn

# ── 3. Flatpak + Flathub ──────────────────────────────────────────────────────

dnf5 install -y flatpak

flatpak remote-add --if-not-exists --system flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ── 4. Distrobox ─────────────────────────────────────────────────────────────

dnf5 install -y distrobox

# ── 5. Disable / clean repos ─────────────────────────────────────────────────

dnf5 -y copr disable lionheartp/Hyprland
rm -f /etc/yum.repos.d/nordvpn.repo
dnf5 clean all

# ── 6. SDDM — Wayland config (fixes black screen on NVIDIA) ──────────────────

mkdir -p /usr/share/sddm/sddm.conf.d
tee /usr/share/sddm/sddm.conf.d/kaamos.conf << "EOF" > /dev/null
[General]
DisplayServer=wayland
Numlock=on

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

mkdir -p /usr/share/wayland-sessions
tee /usr/share/wayland-sessions/hyprland.desktop << "EOF" > /dev/null
[Desktop Entry]
Name=Hyprland
Comment=Kaamos — dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

mkdir -p /usr/lib/tmpfiles.d
tee /usr/lib/tmpfiles.d/kaamos-sddm.conf << "EOF" > /dev/null
d /var/lib/sddm 0750 sddm sddm -
d /var/lib/sddm/themes 0750 sddm sddm -
EOF

# ── 7. NVIDIA Wayland environment variables ───────────────────────────────────

mkdir -p /usr/lib/environment.d
tee /usr/lib/environment.d/10-nvidia-wayland.conf << "EOF" > /dev/null
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF

mkdir -p /usr/lib/modprobe.d
tee /usr/lib/modprobe.d/kaamos-nvidia.conf << "EOF" > /dev/null
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia-drm modeset=1
EOF

# ── 8. Enable system units ────────────────────────────────────────────────────

systemctl enable podman.socket
systemctl enable sddm.service
systemctl enable bluetooth.service
