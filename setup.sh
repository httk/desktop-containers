#!/bin/bash

for DIR in base generic-*/build.sh; do
    (
	cd $(dirname "$DIR")
	./build.sh
    )    
done

for DIR in */build.sh; do

    if [ "${HOST:0:7}" = "generic" ]; then
	continue
    fi
    (
	cd $(dirname "$DIR")
	./build.sh
    )

done

echo "==== All images built"
