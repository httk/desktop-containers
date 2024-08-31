#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends pulseaudio alsa-utils libasound2-plugins
RUN apt-get -y install foot libx11-data weston
RUN apt-get -y install xterm mesa-utils x11-utils xwayland openbox && mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
COPY ./xwayland-exec /usr/bin/xwayland-exec
RUN chmod +x /usr/bin/xwayland-exec
USER "$USER"
EOF

WRAP_NAME="wrap-$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && basename "$(pwd -P)" )-img"

podman build -t "wrap-${WRAP_NAME}-img" .

echo "wrap-${WRAP_NAME}-img" > image.info

echo "Image built. Note, first execution may be very slow to start."
echo "For more info, see README.md"
