This container allows a few different ways of integrating Steam, podman containers, and gamescope.

## Recommended way: Steam on desktop, games on virtual consoles:

1. Access one of your virtual consoles (say, ctrl + alt + f5).
2. Login, and start 'gamescope-vc-daemon.sh'
3. Go back to your main login (usually ctrl + alt + f2).
4. Start steam with 'exec-steam-vc.sh'.
5. Configure steam games that you want to run in fullscreen on the virtual console with 'gamescope-on-vc <args> -- %command%'. Where <args> are the gamescope arguments you want to use, e.g., you can set the launch command to: "gamescope-on-vc -W 1920 -H 1080 --adaptive-sync -- %command%"
6. For any games you rather run in the steam window on your normal desktop, leave the launch command empty.

## Alternative way 1: everything runs on desktop (does not give access to adaptive sync, ability to adjust hadware resolution)

1. Start Steam with exec-steam.sh

## Alternative way 2: everything runs on virtual console

1. Access one of your virtual consoles (say, ctrl + alt + f5).
2. Login, and start 'exec-steam-vc-only.sh'

The steam window runs on virtual console, and when you start games, they will run there as well.


