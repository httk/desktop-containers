#!/bin/bash

cp ../base/gamescope.tgz .

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install xterm mesa-utils libx11-data x11-utils foot xwayland openbox && mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
RUN apt-get -y install --no-install-recommends pulseaudio alsa-utils libasound2-plugins
RUN apt-get -y install --no-install-recommends dbus dbus-x11 bubblewrap && chmod u+s /usr/bin/bwrap && dpkg --add-architecture i386 && apt-get update && apt-get install -y steam-installer
# RUN apt-get -y install gamescope ## Not working for 24.04 :-(
RUN apt-get -y install --no-install-recommends libsdl2-2.0-0 libseat1 libxres1 libinput10
ADD ./gamescope.tgz /
COPY ./gamescope-exec /usr/local/bin/gamescope-exec
COPY ./gamescope-on-vc /usr/local/bin/gamescope-on-vc
RUN ln -s /opt/.X11-unix/X42 /tmp/.X11-unix/X42
USER "$USER"
EOF

WRAP_NAME="wrap-$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && basename "$(pwd -P)" )-img"
podman build -t "wrap-${WRAP_NAME}-img" --label=wrap .
echo "wrap-${WRAP_NAME}-img" > image.info
mkdir -p home

./modify.sh bash -c "su build -c 'git clone https://github.com/ValveSoftware/gamescope.git /opt/gamescope/build && cd /opt/gamescope/build && git checkout 3.13.16.9 && git submodule update --init && meson build/ && ninja -C build/' && cd /opt/gamescope/build && meson install -C build/ --skip-subprojects"

echo "Image built. Note, first execution may be very slow to start."
echo "For more info, see README.md"
