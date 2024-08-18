#!/bin/bash

set -e

BASE="ubuntu:24.04"

LOCALES="$(locale -a | grep -v "POSIX" | tr '\n' ' ')"

cat > ./Containerfile <<EOF
FROM $BASE
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install locales nano git wget
RUN locale-gen ${LOCALES}
RUN update-locale
ENV LANG $LANG
RUN groupadd -r -g 5000 build
RUN useradd -m -u 5000 -g 5000 -c "Build user" "build" 
EOF

FULLNAME="$(getent passwd rar | awk -F':' '{print $5}')"

# We need to handle the user part differently depnding on if it overlaps the default 1000 user or not.
if [ "$UID" == "1000" ]; then

    cat >> Containerfile <<EOF
RUN usermod -l "$USER" ubuntu
RUN groupmod -n "$USER" ubuntu
RUN usermod -d "/home/$USER" -m "$USER"
RUN usermod -c "$FULLNAME" "$USER"
USER $USER
EOF

else

    cat >> Containerfile <<EOF
RUN groupadd -r -g "$UID" "$USER"
RUN useradd -m -u "$UID" -g "$UID" -c "$FULLNAME" "$USER"
USER $USER
EOF

fi

podman build -t wrap-base-img --label=wrap .

echo "wrap-base-img" > image.info
