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
       -e DISPLAY \
       -e XDG_RUNTIME_DIR \
       -e XDG_CURRENT_DESKTOP=GNOME \
       -e QT_QPA_PLATFORM=wayland \
       --device /dev/dri \
       --device /dev/snd \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v $XAUTHORITY \
       -e XAUTHORITY \
       -v "$XDG_RUNTIME_DIR/bus:/tmp/$USER/run/bus" \
       -e DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/$USER/run/bus" \
       -e BROWSER="falkon" \
       -v "$XDG_RUNTIME_DIR/pipewire-0:/tmp/$USER/run/pipewire-0" \
       -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$USER/run/$WAYLAND_DISPLAY:rw" \
       -v "$IMAGE_DIR/home:/home/$USER:rw" \
       $VIDEO_DEVS \
       $FIXES \
       "$IMAGE_NAME" "$@"
