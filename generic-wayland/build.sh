#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install foot libx11-data weston
USER "$USER"
EOF

podman build -t wrap-generic-wayland-img .

echo "wrap-generic-wayland-img" > image.info

echo "Image built. Note, first execution may be very slow to start."
echo
echo "Good test:"
echo "  ./exec-nodri.sh weston-simple-egl"
echo "  ./exec-dri.sh weston-simple-egl"
echo ""
echo "To get a terminal inside the container use:"
echo "  ./exec.sh foot"
echo "  ./exec.sh weston-terminal"
echo
echo "Helpful debug variables that can be set"
echo "  export MESA_DEBUG=1"
echo "  export EGL_LOG_LEVEL=debug"
echo "  export LIBGL_DEBUG=verbose"
echo "  export WAYLAND_DEBUG=1"
