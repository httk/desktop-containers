#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install xterm mesa-utils libx11-data x11-utils foot xwayland openbox && mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
RUN apt-get -y install --no-install-recommends pulseaudio alsa-utils libasound2-plugins
COPY ./xwayland-exec /usr/bin/xwayland-exec
RUN chmod +x /usr/bin/xwayland-exec
USER "$USER"
EOF

podman build -t wrap-generic-xwayland-img .

echo "wrap-generic-xwayland-img" > image.info

echo "Image built. Note, first execution may be very slow to start."
echo "Multiple xwayland instances with --rootless doesn't seem to work well."
echo "Hence non-rootless mode is used, which means the x client will run in an isolated, fixed, box."
echo
echo "Good test:"
echo "  ./exec-dri.sh glxgears"
echo ""
