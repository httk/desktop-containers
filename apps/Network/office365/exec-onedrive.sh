#!/bin/bash

set -e

IMAGE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)
IMAGE_NAME="$(cat "$IMAGE_DIR/image.info")"

if ! podman image exists "$IMAGE_NAME"; then
    echo "You first need to create the image: $IMAGE_NAME"
    exit 1
fi

mkdir -p "$IMAGE_DIR/home"
cd "$IMAGE_DIR/home"

FIXES=""

CRUNVER="$(crun --version | awk '/crun version /{print $3}')"
if ! sort -C -V <<< $'1.9.1\n'"$CRUNVER"; then
    FIXES="$FIXES --read-only=false"
    echo "Warning: read-only turned off due to old version of crun."
fi

VIDEO_DEVS=""
for DEV in /dev/video*; do
    if [ -c $DEV ]; then
      VIDEO_DEVS="--device $DEV $VIDEO_DEVS"
    fi
done

NAME=${IMAGE_NAME%-img}
NAME=${NAME#wrap-}

DESKTOP_FILE=$(find "$IMAGE_DIR/home/.local/share/applications/" -name "*.desktop" | xargs grep -l '^Name=Microsoft OneDrive$')
EXEC=$(cat "$DESKTOP_FILE" | awk -F 'Exec=' '/^Exec/ {print $2}')

# If the container is already runs, execute inside the running container so it can discover that it already runs
ID="$(podman ps -q -f "name=office365_container_runtime")"
if [ -n "$ID" ]; then
    echo "App already running; exec inside running container"
    podman exec "$ID" $EXEC --disable-gpu-memory-buffer-video-frames "$@"
    exit 0
fi

podman run --rm \
       -w "/home/$USER" \
       --name "office365_container_runtime" \
       --user="$USER" \
       --hostname="$NAME" \
       --shm-size=1G \
       --read-only \
       --read-only-tmpfs \
       --systemd=false \
       --cap-drop=ALL \
       --cap-add CAP_SYS_CHROOT \
       --security-opt=no-new-privileges \
       -e LANG \
       -e WAYLAND_DISPLAY \
       -e DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v $XAUTHORITY:$XAUTHORITY \
       -e XAUTHORITY \
       -e XDG_RUNTIME_DIR="/tmp/$USER/run" \
       -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$USER/run/$WAYLAND_DISPLAY:ro" \
       -v "$XDG_RUNTIME_DIR/pipewire-0:/tmp/$USER/run/pipewire-0" \
       -v /dev/dri:/dev/dri \
       -v /dev/snd:/dev/snd \
       --userns=keep-id \
       -v "$IMAGE_DIR/home:/home/$USER:rw" \
       $VIDEO_DEVS \
       $FIXES \
       "$IMAGE_NAME" $EXEC --disable-gpu-memory-buffer-video-frames "$@"

# "$IMAGE_NAME" $EXEC --ozone-platform=wayland --disable-gpu-memory-buffer-video-frames "$@"

# --cap-add=SYS_ADMIN \
#--security-opt seccomp="$IMAGE_DIR/files/chrome.json" \
