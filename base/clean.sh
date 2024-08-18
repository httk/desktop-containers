#!/bin/bash

podman kill $(podman ps --filter label=wrap -q)
podman rm $(podman ps --filter label=wrap -q)
podman rmi $(podman images --filter label=wrap -q)

# Could also do: podman system prune

