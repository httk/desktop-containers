This container is a "safer" Zoom container based on generic-xwayland.
This container sets up an xwayland instance with its own isolated desktop
inside the container and connects it to the wayland display server running
on your desktop.

Security and screen sharing is a diffcult thing. Hence, this container
exposes the Xwayland server inside the container to outside applications,
which, if open there, can be screen-shared with others. To further
facilitate this, a panel (vala-panel) is started which is running outside
the container, but is displayed on the containers X-server (the start button
is at the top right corner of the zoom window). This panel thus allows
you to start applications running on your host system but displayed
within the containerized Zoom desktop.

Start with
  ./exec-zoom.sh
