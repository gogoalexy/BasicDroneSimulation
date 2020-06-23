xhost +
docker run -it --rm \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/dri:/dev/dri \
  --env="DISPLAY=$DISPLAY" \
  --name="gazebo-x11-container" \
  gazebo-x11:1.0 \
  gazebo

xhost -
