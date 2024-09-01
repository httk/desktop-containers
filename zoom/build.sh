#!/bin/bash

set -e

cat > Containerfile <<EOF
FROM wrap-generic-xwayland-img
USER root
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y falkon xdg-utils 
COPY Zoom.pubkey.pem /opt/zoom/Zoom.pubkey.pem
RUN gpg --import /opt/zoom/Zoom.pubkey.pem
USER "$USER"
EOF

NAME="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && basename "$(pwd -P)" )"
podman build -t "wrap-${NAME}-img" --label=wrap .
echo "wrap-${NAME}-img" > image.info
mkdir -p home

./modify.sh bash -c "cd /tmp && wget https://zoom.us/client/latest/zoom_amd64.deb && gpg --verify ./zoom_amd64.deb && apt install -y ./zoom_amd64.deb"

echo "Image built. Note, first execution may be very slow to start."
echo "For more info, see README.md"
