#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install xterm mesa-utils libx11-data x11-utils foot xwayland openbox && mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
RUN apt-get -y install --no-install-recommends pulseaudio alsa-utils libasound2-plugins
RUN apt-get -y install --no-install-recommends dbus dbus-x11 bubblewrap && chmod u+s /usr/bin/bwrap && dpkg --add-architecture i386 && apt-get update && apt-get install -y steam-installer
# RUN apt-get -y install gamescope ## Not working for 24.04 :-(
RUN apt-get -y install hwdata xwayland libbenchmark1.8.3 libdisplay-info1 libevdev-dev libgav1-1 libgudev-1.0-dev libmtdev-dev libseat1 libstb0 libwacom-dev libxcb-ewmh2 libxcb-shape0-dev libxcb-xfixes0-dev libxmu-headers libyuv0 libx11-xcb-dev libxres-dev  libxmu-dev libseat-dev libinput-dev libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-res0-dev libcap-dev wayland-protocols libvulkan-dev libwayland-dev libx11-dev cmake pkg-config meson libxdamage-dev libxcomposite-dev libxcursor-dev libxxf86vm-dev libxtst-dev libxkbcommon-dev libdrm-dev libpixman-1-dev libdecor-0-dev glslang-tools libbenchmark-dev libsdl2-dev libglm-dev libeis-dev libavif-dev
COPY ./gamescope-exec /usr/bin/gamescope-exec
RUN mkdir -p /opt/gamescope && chown build /opt/gamescope && chmod +x /usr/bin/gamescope-exec
USER "$USER"
EOF

podman build -t wrap-steam-img .

echo "wrap-steam-img" > image.info

./modify.sh bash -c "su build -c 'git clone https://github.com/ValveSoftware/gamescope.git /opt/gamescope/build && cd /opt/gamescope/build && git checkout 3.13.16.9 && git submodule update --init && meson build/ && ninja -C build/' && cd /opt/gamescope/build && meson install -C build/ --skip-subprojects"

#./modify.sh bash -c "wget -O ~/steam.deb http://media.steampowered.com/client/installer/steam.deb && apt -y install ~/steam.deb && rm ~/steam.deb"

echo "Image built. Note, first execution may be very slow to start."
echo
echo "Good test:"
echo "  ./exec-steam.sh"
echo ""
