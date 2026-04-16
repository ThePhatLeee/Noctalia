set -ouex pipefail

### 1. Enable the active lionheartp Hyprland COPR
dnf5 -y copr enable lionheartp/Hyprland
#Download the NordVPN repo file directly into the container build
sudo tee /etc/yum.repos.d/nordvpn.repo << "EOF" > /dev/null
[nordvpn]
name=NordVPN
baseurl=https://repo.nordvpn.com/yum/nordvpn/centos/${basearch}/
gpgkey=https://repo.nordvpn.com/gpg/nordvpn_public.asc
gpgcheck=1
EOF

### 2. Install the system base + Noctalia Stack
dnf5 install -y \
    sddm \
    nautilus \
    uwsm \
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
    nix \
    nordvpn

### 3. Disable the COPR
dnf5 -y copr disable lionheartp/Hyprland
rm /etc/yum.repos.d/nordvpn.repo

### 4. Enable System Units
systemctl enable podman.socket
systemctl enable sddm.service
systemctl enable nix-daemon.service
