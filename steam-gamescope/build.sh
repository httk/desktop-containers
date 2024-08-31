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

podman build -t wrap-steam-img .

rm gamescope.tgz

echo "wrap-steam-img" > image.info

echo "Image built. Note, first execution may be very slow to start."
echo
echo "Good test:"
echo "  ./exec-steam.sh"
echo ""
echo "Notes:"
echo " 1. This image sets up a special sharing of X display 42 to the container."
echo "    It is meant to be used with exec-steam-vc. Don't start anything important"
echo "    on that display, as it will be visible inside the container."
echo ""
echo " 2. Fullsceen mode does not work reliably on GNOME"
echo "    It you want to run steam and games inside GNOME in fullscreen,"
echo "    go into the GNOME keyboard configuration and enable"
echo "    a shortcut for fullscreen. Start steam with ./exec-steam-fullscreen.sh,"
echo "    and if you get window decorations, use the shortcut to get rid of them."
echo
echo " 3. If you want to use exec-steam-vc.sh, you also need a copy of gamescope on the host."
echo "    You can use the copy that was built inside base/install/usr/local/bin/gamescope"
echo "    But, you may need to install some libraries, e.g., apt install libsdl2-2.0-0 libseat1"
echo "    Just try to execute it, and install necessary libraries until it works."
echo ""
echo "For more info how to start and use steam, see README.md"

