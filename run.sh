#!/bin/bash

COMM="latest"
CAM="typhoon"
TARGET="NA"

if [ -z "$1" ]; then
	echo "No target specified. (${COMM}/${CAM})"
elif [ "$1" = "${CAM}" ]; then
	TARGET=${CAM}
elif [ "$1" = "${COMM}" ]; then
	TARGET=${COMM}
else
	echo "Unknown target. Abort."
	exit
fi

xhost +
docker run -it --rm \
  --network=host \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/dri:/dev/dri \
  --env="DISPLAY=$DISPLAY" \
  px4-head:${TARGET}

xhost -
