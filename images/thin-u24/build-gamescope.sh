#!/bin/bash

set -e

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update && apt-get -y dist-upgrades
# RUN apt-get -y install gamescope ## Not working for 24.04 :-(
RUN apt-get -y install hwdata xwayland libbenchmark1.8.3 libdisplay-info1 libevdev-dev libgav1-1 libgudev-1.0-dev libmtdev-dev libseat1 libstb0 libwacom-dev libxcb-ewmh2 libxcb-shape0-dev libxcb-xfixes0-dev libxmu-headers libyuv0 libx11-xcb-dev libxres-dev  libxmu-dev libseat-dev libinput-dev libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-res0-dev libcap-dev wayland-protocols libvulkan-dev libwayland-dev libx11-dev cmake pkg-config meson libxdamage-dev libxcomposite-dev libxcursor-dev libxxf86vm-dev libxtst-dev libxkbcommon-dev libdrm-dev libpixman-1-dev libdecor-0-dev glslang-tools libbenchmark-dev libsdl2-dev libglm-dev libeis-dev libavif-dev
USER "$USER"
EOF

podman build -t build-gamescope .

FIXES=""

CRUNVER="$(crun --version | awk '/crun version /{print $3}')"
if ! sort -C -V <<< $'1.9.1\n'"$CRUNVER"; then
    FIXES="$FIXES --read-only=false"
    echo "Warning: read-only turned off due to old version of crun."
fi

IMAGE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)

podman run --rm \
       --user=${USER} \
       --hostname=build-gamescope \
       --cap-drop=ALL \
       --read-only \
       --read-only-tmpfs \
       --systemd=false \
       --security-opt=no-new-privileges \
       -e LANG \
       --userns=keep-id \
       -v "$IMAGE_DIR/outputs:/home/$USER:rw" \
       $FIXES \
       build-gamescope bash -c "mkdir -p ~/build && cd ~/build && git clone https://github.com/ValveSoftware/gamescope.git && cd gamescope && git checkout 3.13.16.9 && git submodule update --init && meson build/ && ninja -C build/ && meson install -C build/ --skip-subprojects --destdir ~/install"

podman rmi build-gamescope
rm -rf outputs/build

(cd outputs/install; tar -zcvf ../../gamescope.tgz .)

echo "Gamescope built; result available in outputs/install"
