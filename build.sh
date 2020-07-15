#!/bin/bash

COMM="latest"
CAM="typhoon"

cd Firmware
git checkout v1.11.0-rc1 && git submodule update --init --recursive
cd ..

if [ -z "$1" ]; then
	echo "No target specified. (${COMM}/${CAM})"
elif [ "$1" = "${CAM}" ]; then
	echo "Building px4-head:${CAM}"
	docker build -t px4-head:${CAM} .
elif [ "$1" = "${COMM}" ]; then
	echo "Building px4-head:${COMM}"
	docker build -t px4-head:${COMM} .
else
	echo "Unknown target."
fi
