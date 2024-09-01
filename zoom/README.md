This container is a zoom container based on generic-xwayland.
This container sets up an xwayland instance inside the container and connects it to the wayland display server running on your desktop.

Security and screen sharing is a diffcult thing. Hence, this container
exposes the Xwayland server inside the container to outside applications,
which, if open there, can be screen-shared with others. To further
facilitate this, a panel (vala-panel) is started which is running outside
the container, but is displayed on the containers X-server. This panel
thus allows you to further start applications on your host system
which can then be screen shared with Zoom running in the container.

Run with
  ./exec-zoom.sh

