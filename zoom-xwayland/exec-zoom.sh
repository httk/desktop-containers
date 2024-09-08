#!/bin/bash

set -e

if [ ! -e ./image.info ]; then
    echo "You first need to run setup.sh to create an image."
    exit 1
fi

FIXES=""

CRUNVER="$(crun --version | awk '/crun version /{print $3}')"
if ! sort -C -V <<< $'1.9.1\n'"$CRUNVER"; then
    FIXES="$FIXES --read-only=false"
    echo "Warning: read-only turned off due to old version of crun."
fi

IMAGE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)
IMAGE_NAME="$(cat image.info)"
NAME=${IMAGE_NAME%-img}
NAME=${NAME#wrap-}

mkdir -p /tmp/.X11-unix/screenshare
ln -sf screenshare/X101 /tmp/.X11-unix/X101

echo "Note: start software you want to screen-share with zoom on DISPLAY=:101"

VIDEO_DEVS=""
for DEV in /dev/video*; do
    if [ -c $DEV ]; then
      VIDEO_DEVS="--device $DEV $VIDEO_DEVS"
    fi
done

podman run --rm \
       -w "/home/$USER" \
       --hostname="$NAME" \
       --name="$NAME" \
       --user="$USER" \
       --cap-drop=ALL \
       --cap-add sys_chroot \
       --read-only \
       --read-only-tmpfs \
       --systemd=false \
       --security-opt=no-new-privileges \
       --userns=keep-id \
       -e LANG \
       -e WAYLAND_DISPLAY \
       -e XDG_RUNTIME_DIR \
       -e XDG_CURRENT_DESKTOP=GNOME \
       -e QT_QPA_PLATFORM=wayland \
       --device /dev/dri \
       --device /dev/snd \
       -e BROWSER="falkon" \
       -v "$XDG_RUNTIME_DIR/pipewire-0:/tmp/$USER/run/pipewire-0" \
       -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$USER/run/$WAYLAND_DISPLAY:rw" \
       -v "$IMAGE_DIR/home:/home/$USER:rw" \
       -v "/tmp/.X11-unix/screenshare:/tmp/.X11-unix:rw" \
       $VIDEO_DEVS \
       $FIXES \
       "$IMAGE_NAME" bash -c "pipewire-pulse & xwayland-wm-exec zoom" &

PODMANPID=$!
sleep 5
env -u WAYLAND_DISPLAY GDK_BACKEND=x11 XDG_SESSION_TYPE=x11  QT_QPA_PLATFORM=x11 SDL_VIDEODRIVER=x11 DISPLAY=:101 vala-panel
podman wait "$NAME"
rm -f /tmp/.X11-unix/X101
rm -rf /tmp/.X11-unix/screenshare

#       -e DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/$USER/run/bus" \
#       -v "$XDG_RUNTIME_DIR/bus:/tmp/$USER/run/bus" \
