# ── Stage 0: build context ───────────────────────────────────────────────────
FROM scratch AS ctx
COPY build_files /

# ── Stage 1: pre-built NVIDIA open kernel modules from ublue ─────────────────
# akmods-nvidia-open contains RPMs pre-compiled against the Fedora 44 kernel.
# This is the only correct approach for bootc — /usr/lib/modules is read-only
# at runtime so DKMS and akmod builds cannot happen post-install.
# Use nvidia-open for Turing (RTX 20xx) and newer.
# Use akmods-nvidia (not -open) only for pre-Turing (GTX 10xx and older).
FROM ghcr.io/ublue-os/akmods-nvidia-open:main-44 AS nvidia-rpms

# ── Stage 2: Noctalia OS ─────────────────────────────────────────────────────
FROM quay.io/fedora/fedora-bootc:44

# ── RPMFusion (required for NVIDIA userspace packages) ───────────────────────
RUN dnf5 install -y \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# ── NVIDIA open kmod from ublue akmods staging image ────────────────────────
COPY --from=nvidia-rpms /rpms/ /tmp/nvidia-rpms/
RUN dnf5 install -y \
      /tmp/nvidia-rpms/ublue-os/ublue-os-nvidia*.rpm \
      /tmp/nvidia-rpms/kmods/kmod-nvidia-open*.rpm && \
    rm -rf /tmp/nvidia-rpms

# ── NVIDIA userspace ─────────────────────────────────────────────────────────
RUN dnf5 install -y \
      nvidia-driver \
      nvidia-driver-libs \
      libva-nvidia-driver \
      egl-wayland && \
    dnf5 clean all

# ── NVIDIA kernel arguments ──────────────────────────────────────────────────
# All three required — without them SDDM shows a black screen on NVIDIA.
# Do NOT add nvidia_drm.fbdev=0 — breaks display on driver 580+.
RUN bootc kargs set -- \
      rd.driver.blacklist=nouveau \
      modprobe.blacklist=nouveau \
      nvidia-drm.modeset=1

# ── Noctalia build ───────────────────────────────────────────────────────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# ── Verify ───────────────────────────────────────────────────────────────────
RUN bootc container lint
