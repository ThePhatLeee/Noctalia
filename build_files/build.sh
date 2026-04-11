set -ouex pipefail

### 1. Enable the active lionheartp Hyprland COPR
dnf5 -y copr enable lionheartp/Hyprland

### 2. Install the system base + Noctalia Stack
dnf5 install -y \
    sddm \
    uwsm \
    xdg-desktop-portal-hyprland \
    polkit-gnome \
    swaync \
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
    gpu-screen-recorder

### 3. Disable the COPR
dnf5 -y copr disable lionheartp/Hyprland

### 4. Enable System Units
systemctl enable podman.socket
systemctl enable sddm.service
