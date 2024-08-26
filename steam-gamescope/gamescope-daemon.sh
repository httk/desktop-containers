#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: gamescope-daemon.sh <syncronization home directory>"
    exit 1
fi

HOMEDIR="$1"
SYNCDIR="${HOMEDIR}/.local/state/gamescope-daemon"
mkdir -p "${SYNCDIR}"
touch "${SYNCDIR}/args"

inotifywait -e modify "${SYNCDIR}/args"

while [ "0" == "0" ]; do

    PARAMS=$(cat "${SYNCDIR}/args")

    # Sanitization
    ARGS=$(printf "%s\n" "$PARAMS" | awk '
    {
        for (i=1; i<NF; i++) {
            processString($i)
        }
    }

    function processString(val) {
          if(val == "-H") {i=i+1; a=int($i); if (a > 0 && a < 100000) {printf("%s %d ","-H",a)}};
          if(val == "-W") {i=i+1; a=int($i); if (a > 0 && a < 100000) {printf("%s %d ","-W",a)}};
          if(val == "-h") {i=i+1; a=int($i); if (a > 0 && a < 100000) {printf("%s %d ","-h",a)}};
          if(val == "-w") {i=i+1; a=int($i); if (a > 0 && a < 100000) {printf("%s %d ","-w",a)}};
          if(val == "-r") {i=i+1; a=int($i); if (a > 0 && a < 100000) {printf("%s %d ","-r",a)}};	  
    }
    ')

    #home/gamescope -- bash -c "echo \"\${DISPLAY}\" > checkme.txt && xterm"  &
    #"$HOMEDIR/gamescope" ${ARGS} -- bash -c "echo \"\${DISPLAY}\" > \"${SYNCDIR}/display\" && xterm" &
    echo "Executng: "  "$HOMEDIR/gamescope" ${ARGS} -- bash -c "echo \"\${DISPLAY}\" > \"${SYNCDIR}/display\" && xterm" 
    "$HOMEDIR/gamescope" ${ARGS} -- bash -c "echo \"\${DISPLAY}\" > \"${SYNCDIR}/display\" && xterm" &
    GSPID="$!"

    inotifywait -e modify "${SYNCDIR}/args"

    # Somewhat gracefully kill the old gamescope process
    sleep 5 &
    kill "$GSPID" || true
    wait -n

    if kill -0 "$GSPID" 2>/dev/null; then
	kill -9 "$GSPID"
    fi
    
done
