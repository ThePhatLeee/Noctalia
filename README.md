# Noctalia

> A minimal, immutable Fedora desktop built on [bootc](https://bootc-dev.github.io/bootc/), powered by Hyprland and NVIDIA open drivers.

[![Build](https://github.com/ThePhatLeee/Noctalia/actions/workflows/build.yml/badge.svg)](https://github.com/ThePhatLeee/Noctalia/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

---

## What is Noctalia

Noctalia is a custom Fedora bootc OCI image. It starts from a clean `fedora-bootc:44` base and adds exactly what is needed to run a fast, keyboard-driven Wayland desktop with NVIDIA GPU support — nothing more.

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
- **noctalia-hyprland-meta** — Noctalia's curated Hyprland toolkit
- `hyprpolkitagent`, `hyprpaper`, `hypridle`, `hyprlock`, `hyprcursor`
- `hyprshot`, `hyprpicker`, `hyprsunset`, `hyprsysteminfo`
- `hyprpwcenter`, `hyprshutdown`, `hyprlauncher`
- `kanshi`, `waypaper`, `cliphist`, `nwg-look`, `qt6ct`
- `gpu-screen-recorder`

### Apps & Package Management
- **Flatpak** with **Flathub** registered system-wide — install any app with `flatpak install flathub ...`
- **Distrobox** + **Podman** — run any Linux distro as a container for development or CLI tools
- **Nautilus** — file manager

### VPN
- **NordVPN** — installed and ready, activate with `nordvpn login`

---

## Installation

### Rebase from any Fedora Atomic system

```bash
sudo bootc switch ghcr.io/thephatleee/noctalia:latest
systemctl reboot
```

That's it. On next boot you are on Noctalia.

### Fresh install via ISO

Download the latest ISO from the [Releases](https://github.com/ThePhatLeee/Noctalia/releases) page or trigger a disk image build manually from the Actions tab. The installer will set up Noctalia directly on bare metal.

---

## First Boot

### Add Flathub apps

Flathub is registered but no apps are pre-installed. Install what you need:

```bash
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.brave.Browser
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.valvesoftware.Steam
```

### Set up a Distrobox development container

```bash
# Create a Fedora container for development
distrobox create --name dev --image fedora:42
distrobox enter dev

# Inside the container, install anything with dnf
sudo dnf install gcc rustc nodejs python3 ...
```

Apps installed in a Distrobox container can be exported to the host desktop:

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

Noctalia builds automatically every day at 10:05 UTC. To pull the latest image:

```bash
sudo bootc upgrade
systemctl reboot
```

To check what image you are currently running:

```bash
bootc status
```

To roll back if something goes wrong:

```bash
sudo bootc rollback
systemctl reboot
```

---

## Building Locally

Requires [just](https://just.systems) and Podman.

```bash
git clone https://github.com/ThePhatLeee/Noctalia
cd Noctalia

# Build the container image
just build

# Build a QCOW2 VM image for testing
just build-qcow2

# Boot it in a VM
just spawn-vm

# Once verified, rebase your machine
sudo bootc switch ghcr.io/thephatleee/noctalia:latest
```

---

## How It Works

```
quay.io/fedora/fedora-bootc:44          ← clean Fedora base
        │
        ├── NVIDIA open kmod            ← pre-built by ublue akmods, no DKMS
        ├── RPMFusion NVIDIA userspace  ← nvidia-driver, egl-wayland, libva
        ├── Hyprland stack              ← lionheartp COPR + noctalia-hyprland-meta
        ├── Flatpak + Flathub           ← user apps
        ├── Distrobox + Podman          ← dev environments
        └── NordVPN                     ← VPN
                │
                ▼
        ghcr.io/thephatleee/noctalia:latest
```

The image is built by GitHub Actions on every push to `main` and on a daily schedule. It is signed with [cosign](https://github.com/sigstore/cosign) using the key at `cosign.pub`.

---

## Relationship to Fedora Hyprland Atomic

Noctalia is the opinionated personal build. A parallel project — **Fedora Hyprland Atomic** — aims to upstream a clean, Fedora-policy-compliant Hyprland variant into the official Fedora Atomic Desktop family alongside Silverblue, Kinoite, and Sway Atomic.

The Fedora spin uses only official Fedora repos (no COPR, no RPMFusion, no proprietary software) and is intended for submission to [workstation-ostree-config](https://pagure.io/workstation-ostree-config). Users of that spin can layer NVIDIA drivers themselves via `rpm-ostree install akmod-nvidia` after installation.

---

## Verifying the Image

```bash
cosign verify \
  --key cosign.pub \
  ghcr.io/thephatleee/noctalia:latest
```

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).
