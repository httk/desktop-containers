#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install term mesa-utils libx11-data x11-utils
USER "$USER"
EOF

podman build -t wrap-generic-x11-img .

echo "wrap-generic-x11-img" > image.info

echo "Image built. Note, first execution may be very slow to start."
echo
echo "Important: this container allows x11 programs to access your x11 instance outside the container."
echo "This is not very safe: they can access all windows, run keyloggers, etc."
echo "A better option is implemented in generic-xwayland, which runs"
echo "an isolated xwayland server in the container."
echo
echo "Good tests:"
echo "  vblank_mode=0 ./exec-nodri.sh glxgears"
echo "  vblank_mode=0 ./exec-dri.sh glxgears"
