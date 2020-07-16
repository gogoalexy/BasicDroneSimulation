#!/bin/bash

new_flag=''
reuse_flag=''
image_flag=''

print_usage() {
	printf "Usage: ..."
}

while getopts 'n:r:i:' flag; do
	case "${flag}" in
		n) new_flag=$OPTARG ;;
		r) reuse_flag=$OPTARG ;;
		i) image_flag=$OPTARG ;;
		*) print_usage
			exit 1 ;;
	esac
done

xhost +

if [ $reuse_flag ]; then
	if docker ps -a | grep -q $reuse_flag; then
			echo "Container exists, reuse."
			docker start -i $reuse_flag
	else
		echo "Container does not exist, please try to run it (-n) first."
	fi
elif [ $new_flag ]; then
	if [ $image_flag ]; then
		docker run -it \
		  --network=host \
		  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
		  --device=/dev/dri:/dev/dri \
		  --env="DISPLAY=$DISPLAY" \
		  --name=$new_flag \
		  $image_flag
	else
		echo "Please specify image name (-i)."
	fi
fi

xhost -

