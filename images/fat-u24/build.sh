#!/bin/bash

set -e

if [ -z "$XDG_RUNTIME_DIR" -o -z "$USER" -o -z "$UID" -o -z "$LANG" ]; then
    echo "The following env variables must be set: XDG_RUNTIME_DIR, USER, UID, LANG"
    exit 1
fi

BASE="ubuntu:24.04"

# The sed 's/.utf8/.UTF-8/' fixes incorrectly specified locales from pre-GNOME 3.18 I think.
LOCALES="$(locale -a | grep -v "POSIX" | sed 's/.utf8/.UTF-8/' | tr '\n' ' ')"

cat > ./Containerfile <<EOF
FROM $BASE
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y dist-upgrade && apt-get install -y --reinstall ca-certificates
RUN apt-get -y --no-install-recommends install locales nano wget bash curl git jq less net-tools p7zip-full patch pciutils pkg-config procps psmisc psutils rsync screen unzip xmlstarlet xz-utils python3 python3-pip python3-setuptools python3-venv libx11-data x11-utils gpg gpg-agent xdg-utils iproute2 pipewire pipewire-alsa pipewire-pulse alsa-utils libasound2-plugins foot weston xterm mesa-utils xwayland openbox dbus dbus-x11 bubblewrap steam-installer libsdl2-2.0-0 libseat1 libxres1 libinput10 falkon libpipewire-0.3-0 libpipewire-0.3-common pipewire-bin xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk && apt-get clean autoclean -y && apt-get autoremove -y && rm -rf /var/tmp/* && rm -rf /tmp/*
# RUN apt-get -y install gamescope ## Not working for 24.04 :-(
RUN chmod u+s /usr/bin/bwrap
ADD ./files/gamescope.tgz /
COPY ./files/en_SE.locale /tmp/en_SE.locale
COPY ./files/xwayland-exec /usr/bin/xwayland-exec
COPY ./files/xwayland-wm-exec /usr/bin/xwayland-wm-exec
COPY ./files/gamescope-exec /usr/local/bin/gamescope-exec
COPY ./files/gamescope-on-vc /usr/local/bin/gamescope-on-vc
RUN chmod +x /usr/bin/xwayland-exec /usr/bin/xwayland-wm-exec
RUN mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix
RUN ln -s /opt/.X11-unix/X42 /tmp/.X11-unix/X42
RUN test ! -e /usr/share/i18n/locales/en_SE && cp /tmp/en_SE.locale /usr/share/i18n/locales/en_SE && localedef -i en_SE -f UTF-8 en_SE.UTF-8 && echo "# en_SE.UTF-8 UTF-8" >> "/etc/locale.gen" && echo "en_SE.UTF-8 UTF-8" >> "/usr/share/i18n/SUPPORTED"
RUN locale-gen ${LOCALES} && update-locale "LANG=$LANG"
ENV LANG $LANG
RUN groupadd -r -g 5000 build && useradd -m -u 5000 -g 5000 -c "Build user" "build" && ln -s "/tmp/$USER/run" "$XDG_RUNTIME_DIR"
EOF

## No longer works, and no longer needed?
## echo "# en_SE.UTF-8 UTF-8" >> "/etc/locale.gen" && locale-gen ${LOCALES}

FULLNAME="$(getent passwd rar | awk -F':' '{print $5}')"

# We need to handle the user part differently depnding on if it overlaps the default 1000 user or not.
if [ "$UID" == "1000" ]; then

    cat >> Containerfile <<EOF
RUN usermod -l "$USER" ubuntu && groupmod -n "$USER" ubuntu && usermod -d "/home/$USER" -m "$USER" && usermod -c "$FULLNAME" "$USER" && mkdir /tmp/$USER && chown "$USER:$USER" "/tmp/$USER" && chmod 0700 "/tmp/$USER" && mkdir "/tmp/$USER/run" && chown "$USER:$USER" "/tmp/$USER/run" && chmod 0700 "/tmp/$USER/run"
USER $USER
EOF

else

    cat >> Containerfile <<EOF
RUN groupadd -r -g "$UID" "$USER" && useradd -m -u "$UID" -g "$UID" -c "$FULLNAME" "$USER" && mkdir /tmp/$USER && chown "$USER:$USER" "/tmp/$USER" && chmod 0700 "/tmp/$USER" && mkdir "/tmp/$USER/run" && chown "$USER:$USER" "/tmp/$USER/run" && chmod 0700 "/tmp/$USER/run"
USER $USER
EOF

fi

podman build -t wrap-fat-u24-img --label=wrap .

echo "wrap-fat-u24-img" > image.info
