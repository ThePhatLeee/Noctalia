set -ouex pipefail

### 0. Ensure COPR support exists (needed in minimal build roots)
dnf5 install -y dnf5-plugins

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
    nordvpn \
    flatpak \
    distrobox

### 3. Disable the COPR
dnf5 -y copr disable lionheartp/Hyprland
rm /etc/yum.repos.d/nordvpn.repo

### 4. Enable System Units
systemctl enable podman.socket
systemctl enable sddm.service

### 5. Set up user-level flatpak service to install Firefox on first login
mkdir -p /etc/systemd/user/default.target.wants

cat > /etc/systemd/user/install-user-flatpaks.service << 'EOF'
[Unit]
Description=Install user Flatpaks on first login
After=network-online.target
Wants=network-online.target
ConditionPathExists=!%h/.local/share/.flatpak-setup-done

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
ExecStart=/usr/bin/flatpak install --user -y flathub org.mozilla.firefox
ExecStartPost=/usr/bin/bash -c 'mkdir -p "%h/.local/share" && touch "%h/.local/share/.flatpak-setup-done"'
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

ln -s /etc/systemd/user/install-user-flatpaks.service \
    /etc/systemd/user/default.target.wants/install-user-flatpaks.service
