#!/usr/bin/env bash
set -ouex pipefail

# ── 1. Repos ─────────────────────────────────────────────────────────────────

### Enable the active lionheartp Hyprland COPR
dnf5 -y copr enable lionheartp/Hyprland

### NordVPN repo
# Note: using tee directly — we are already root inside a container build
tee /etc/yum.repos.d/nordvpn.repo << "EOF" > /dev/null
[nordvpn]
name=NordVPN
baseurl=https://repo.nordvpn.com/yum/nordvpn/centos/${basearch}/
gpgkey=https://repo.nordvpn.com/gpg/nordvpn_public.asc
gpgcheck=1
EOF

# ── 2. Install the Noctalia Stack ────────────────────────────────────────────

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

# ── 3. Flatpak + Flathub ─────────────────────────────────────────────────────

dnf5 install -y flatpak

# Register Flathub as a system-wide remote (available to all users, no apps pre-installed)
flatpak remote-add --if-not-exists --system flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ── 4. Distrobox ─────────────────────────────────────────────────────────────

dnf5 install -y distrobox

# ── 5. Disable / clean up repos ──────────────────────────────────────────────

dnf5 -y copr disable lionheartp/Hyprland
rm -f /etc/yum.repos.d/nordvpn.repo

# ── 6. SDDM — Wayland mode (fixes black screen on NVIDIA + Hyprland) ─────────

# Vendor config: put in /usr/share so it is image-managed and read-only
# Users can override via /etc/sddm.conf.d/ at runtime
mkdir -p /usr/share/sddm/sddm.conf.d
tee /usr/share/sddm/sddm.conf.d/noctalia.conf << EOF > /dev/null
[General]
DisplayServer=wayland
Numlock=on

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

# Wayland session entry so SDDM knows how to launch Hyprland
mkdir -p /usr/share/wayland-sessions
tee /usr/share/wayland-sessions/hyprland.desktop << EOF > /dev/null
[Desktop Entry]
Name=Hyprland
Comment=Noctalia — dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Mutable SDDM theme directory on the immutable filesystem
# tmpfiles.d creates /var/lib/sddm/themes at boot — users drop themes there
mkdir -p /usr/lib/tmpfiles.d
tee /usr/lib/tmpfiles.d/noctalia-sddm.conf << EOF > /dev/null
d /var/lib/sddm 0750 sddm sddm -
d /var/lib/sddm/themes 0750 sddm sddm -
EOF

# ── 7. Enable System Units ───────────────────────────────────────────────────

systemctl enable podman.socket
systemctl enable sddm.service
