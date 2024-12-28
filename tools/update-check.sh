#!/bin/bash

set -e 

SCRIPTPATH="$(dirname -- "$(realpath -- "$0")")"

if [ "$1" == "-h" ]; then
    echo "Usage: $0 [<app dir>]"
    exit 0
fi

DEST="$1"
if [ "$DEST" == "" ]; then
    APP=$(basename -- "$(pwd)")
    DEST="."
else
    APP=$(basename -- "$DEST")
fi
shift 1

DEST_ABSPATH="$(cd -- "$DEST"; pwd -P)"
cd "$DEST_ABSPATH"

"$SCRIPTPATH/launch.sh" update-check
