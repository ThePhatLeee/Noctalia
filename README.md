# Kaamos

> A minimal, immutable Fedora desktop built on [bootc](https://bootc-dev.github.io/bootc/), powered by Hyprland and NVIDIA open drivers.

*Kaamos* — Finnish for the polar night. The period when the sun does not rise.

[![Build](https://github.com/ThePhatLeee/Kaamos/actions/workflows/build.yml/badge.svg)](https://github.com/ThePhatLeee/Kaamos/actions/workflows/build.yml)
[![ISO Release](https://img.shields.io/github/v/release/ThePhatLeee/Kaamos?filter=iso-*&label=ISO&color=blue)](https://github.com/ThePhatLeee/Kaamos/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

---

## What is Kaamos

Kaamos is a custom Fedora bootc OCI image. It starts from a clean `fedora-bootc:44` base and adds exactly what is needed to run a fast, keyboard-driven Wayland desktop with NVIDIA GPU support — nothing more.

The OS itself is **read-only and atomic**. Updates are delivered as new container images and are always rollback-safe. User applications come from **Flathub**. Development environments live in **Distrobox** containers. Proprietary extras like NVIDIA drivers and NordVPN are baked in at build time so they are always present and always the right version.

---

## What's Inside

### Base
- **Fedora 44** (`quay.io/fedora/fedora-bootc:44`) — clean, minimal, no desktop bloat
- **bootc** — atomic updates, instant rollback, cosign-verified image signing

### GPU
- **NVIDIA open kernel module** — pre-built for the F44 kernel via ublue akmods, no DKMS at runtime
- **RPMFusion NVIDIA userspace** — `nvidia-driver`, `egl-wayland`, `libva-nvidia-driver`
- Kernel args set at build time: `nouveau` blacklisted, `nvidia-drm.modeset=1` enabled
- Wayland environment variables baked in so Hyprland renders correctly on NVIDIA from first boot

### Desktop
- **Hyprland** — dynamic tiling Wayland compositor (lionheartp COPR)
- **SDDM** — display manager configured for Wayland mode
- `hyprpolkitagent`, `hyprpaper`, `hypridle`, `hyprlock`, `hyprcursor`
- `hyprshot`, `hyprpicker`, `hyprsunset`, `hyprsysteminfo`
- `hyprpwcenter`, `hyprshutdown`, `hyprlauncher`
- `kanshi`, `waypaper`, `cliphist`, `nwg-look`, `qt6ct`
- `gpu-screen-recorder`

### Apps & Package Management
- **Flatpak** with **Flathub** registered system-wide
- **Distrobox** + **Podman** — run any Linux distro as a container
- **Nautilus** — file manager

### VPN
- **NordVPN** — installed and ready, activate with `nordvpn login`

---

## Installation

### Rebase from any Fedora Atomic system

```bash
sudo bootc switch ghcr.io/thephatleee/kaamos:latest
systemctl reboot
```

### Fresh install via ISO

Download the latest ISO directly from the **[Releases](https://github.com/ThePhatLeee/Kaamos/releases)** page — a new ISO is built automatically on the 1st of every month and kept for 30 days.

---

## First Boot

### Add Flathub apps

```bash
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.brave.Browser
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.valvesoftware.Steam
```

### Set up a Distrobox development container

```bash
distrobox create --name dev --image fedora:42
distrobox enter dev
```

Apps installed in a container can be exported to the host:

```bash
distrobox-export --app code
distrobox-export --app nvim
```

### NordVPN

```bash
nordvpn login
nordvpn connect
```

---

## Staying Up to Date

Kaamos builds automatically every day at 10:05 UTC.

```bash
# Pull the latest image
sudo bootc upgrade
systemctl reboot

# Check current image
bootc status

# Roll back if needed
sudo bootc rollback
systemctl reboot
```

---

## Building Locally

Requires [just](https://just.systems) and Podman.

```bash
git clone https://github.com/ThePhatLeee/Kaamos
cd Kaamos

just build          # build the container image
just build-qcow2    # build a VM image for testing
just spawn-vm       # boot it in a VM
```

---

## How It Works

```
quay.io/fedora/fedora-bootc:44
        │
        ├── NVIDIA open kmod (ublue akmods, no DKMS)
        ├── RPMFusion NVIDIA userspace
        ├── Hyprland stack (lionheartp COPR)
        ├── Flatpak + Flathub
        ├── Distrobox + Podman
        └── NordVPN
                │
                ▼
        ghcr.io/thephatleee/kaamos:latest
```

Built by GitHub Actions on every push and daily. Signed with [cosign](https://github.com/sigstore/cosign).

---

## Verifying the Image

```bash
cosign verify \
  --key cosign.pub \
  ghcr.io/thephatleee/kaamos:latest
```

---

## Relationship to Fedora Hyprland Atomic

Kaamos is the opinionated personal build. A parallel project — **Fedora Hyprland Atomic** — aims to contribute a clean, Fedora-policy-compliant Hyprland variant upstream into the official Fedora Atomic Desktop family alongside Silverblue, Kinoite, and Sway Atomic. That spin uses only official Fedora repos with no proprietary software — users layer NVIDIA and other extras themselves after installation.

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).
