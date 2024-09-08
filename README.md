# Desktop containers

This provides a set of helper scripts to set up containers using the container software 'podman' in non-root mode to more safely run typical desktop software.

The design is that each subdirectory of this repository represents either a general container (`generic-*`) or a container for running some specific software. Most of them uses a subdirectory 'home' for the home directory shown to the running software. Refer to README.md in the subdirectory for more information.

Since the 'state' of the containers is stored in `home`, the containers themselves are essentially stateless. This means you can at any time run `podman system reset` to purge the containers, and then go back and follow the instructions below to re-build the containers you need. (Note: `podman system reset` deletes *all* podman images and containers, not just the ones associated with these scripts.)

## Base container

Almost all containers work off 'base', so start with:
```
  cd base
  ./build.sh
```

If you think you are interested in running anything using 'gamescope' (mostly relevant for games) also run `./build-gamescope.sh` in the base directory.

There is also a `base-u20`, in case you for some reason need to run something in Ubuntu 20.04.

## Generic containers

Use the `generic-*/build.sh` scripts to build the generic containers you need.

## Software-specific containers

Use the `*/build.sh` scripts to build containers for the software you need. Refer to `README.md` in the respective directory for more information.


