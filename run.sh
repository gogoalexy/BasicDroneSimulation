#!/bin/bash

xhost +
docker run -it --rm \
  --network=host \
  -p 5600:5600/udp \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/dri:/dev/dri \
  --env="DISPLAY=$DISPLAY" \
  px4-head:typhoon

xhost -
