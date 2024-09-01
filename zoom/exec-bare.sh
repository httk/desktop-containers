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
       -e LANG \
	--userns=keep-id \
	-e WAYLAND_DISPLAY \
	-e XDG_RUNTIME_DIR="/tmp/$USER" \
	--userns=keep-id \
	--device /dev/dri \
	--device /dev/snd \
	-v "$XDG_RUNTIME_DIR/pipewire-0:/tmp/$USER/pipewire-0" \
	-v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$USER/$WAYLAND_DISPLAY:ro" \
	-v "$IMAGE_DIR/home:/home/$USER:rw" \
	$VIDEO_DEVS \
        $FIXES \
        "$IMAGE_NAME" "$@"
