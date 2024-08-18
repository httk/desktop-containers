#!/bin/bash

set -e

if [ ! -e ./image.info ]; then
    echo "You first need to run setup.sh to create an image."
    exit 1
fi

IMAGE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)

podman run --rm \
       --user="$USER" \
       --hostname="$(cat image.info)" \
       --cap-drop=ALL \
       --read-only \
       --read-only-tmpfs \
       --systemd=false \
       --security-opt=no-new-privileges \
	-e LANG \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY \
	-v $XAUTHORITY:$XAUTHORITY \
	-e XAUTHORITY \
	-e vblank_mode \
	--userns=keep-id \
	-v /dev/dri:/dev/dri \
	-v "$IMAGE_DIR/home:/home/$USER:rw" \
        "$(cat image.info)" "$@"

