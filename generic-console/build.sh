#!/bin/bash

cat > Containerfile <<EOF
FROM wrap-base-img
USER root
RUN apt-get update
RUN apt-get -y dist-upgrade
USER "$USER"
EOF

podman build -t wrap-generic-console-img --label=wrap .

mkdir -p home

echo "wrap-generic-console-img" > image

echo "Image built. Note, first execution may be very slow to start."
