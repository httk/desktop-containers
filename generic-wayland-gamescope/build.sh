#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install foot libx11-data xterm mesa-utils x11-utils
# RUN apt-get -y install gamescope ## Not working for 24.04 :-(
RUN apt-get -y install hwdata xwayland libbenchmark1.8.3 libdisplay-info1 libevdev-dev libgav1-1 libgudev-1.0-dev libmtdev-dev libseat1 libstb0 libwacom-dev libxcb-ewmh2 libxcb-shape0-dev libxcb-xfixes0-dev libxmu-headers libyuv0 libx11-xcb-dev libxres-dev  libxmu-dev libseat-dev libinput-dev libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-res0-dev libcap-dev wayland-protocols libvulkan-dev libwayland-dev libx11-dev cmake pkg-config meson libxdamage-dev libxcomposite-dev libxcursor-dev libxxf86vm-dev libxtst-dev libxkbcommon-dev libdrm-dev libpixman-1-dev libdecor-0-dev glslang-tools libbenchmark-dev libsdl2-dev libglm-dev libeis-dev libavif-dev
RUN mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
RUN mkdir -p /opt/gamescope
RUN chown build /opt/gamescope
COPY ./gamescope-exec /usr/bin/gamescope-exec
RUN chmod +x /usr/bin/gamescope-exec
USER "$USER"
EOF

podman build -t wrap-generic-wayland-gamescope-img .

echo "wrap-generic-wayland-gamescope-img" > image.info

./modify.sh bash -c "su build -c 'git clone https://github.com/ValveSoftware/gamescope.git /opt/gamescope/build && cd /opt/gamescope/build && git checkout 3.13.16.9 && git submodule update --init && meson build/ && ninja -C build/' && cd /opt/gamescope/build && meson install -C build/ --skip-subprojects"

echo "Image built. Note, first execution may be very slow to start."
echo
echo "Good test:"
echo "  ./exec-dri.sh glxgears"
echo ""
