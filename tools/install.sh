#!/bin/bash

set -e 

SCRIPTPATH="$(dirname -- "$(realpath -- "$0")")"

if [ -z "$1" -o "$1" == "-h" -o "$1" == "--help" -o ! -e "$1" ]; then
    echo "Usage: $0 <compose.yaml> [<install dest>]"
    exit 0
fi

SOURCE="$1"
DEST="$2"
if [ -z "$DEST" ]; then
    SOURCE_NAME=$(basename -- "$SOURCE")
    APP="${SOURCE_NAME%.*}"
    DEST="./$APP"
else
    APP=$(basename -- "$DEST")
fi

if ! yq -r '."x-application"' "$SOURCE" > /dev/null 2>&1 || [ "$(yq -r '."x-application"' "$SOURCE" 2>/dev/null)" == "null" ]; then
    echo "This is not a desktop-container yaml file."
    #yq -r '."x-application"' "$SOURCE" ## uncomment to debug
    exit 1
fi

mkdir -p "$DEST"
DEST_ABSPATH="$(cd -- "$DEST"; pwd -P)"
ln -sf "$(realpath -- "$SOURCE")" "$DEST_ABSPATH/compose.yaml"
cd "$DEST_ABSPATH"

if [ ! -e override.yaml ]; then
    if [ "$(yq -r '."x-application"."override-default"' compose.yaml)" != "null" ]; then
	yq -r '."x-application"."override-default"' compose.yaml > override.yaml
    else
	cat <<EOF > override.yaml
version: "3.8"
EOF
    fi
fi

if [ ! -e .env ]; then
    if [ "$(yq -r '."x-application"."env-default"' compose.yaml)" != "null" ]; then
	yq -r '."x-application"."env-default"' compose.yaml > .env
    else
	cat <<EOF > .env
# No configurable options
EOF
    fi
    if [ ! -e env ]; then
	ln -s .env env
    fi
fi

if [ "$(yq -r '."x-application"."readme"' compose.yaml)" != "null" ]; then
    yq -r '."x-application"."readme"' compose.yaml > README.md
else
    cat <<EOF > README.md
This app is missing a README.
EOF
fi

"$SCRIPTPATH/launch.sh" install-prepare
"$SCRIPTPATH/launch.sh" install
"$SCRIPTPATH/post-install.sh"
