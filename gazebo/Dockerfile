FROM gazebo:libgazebo9-bionic

ENV WORKSPACE_DIR /root
WORKDIR /root

RUN \
  apt-get update && \
  apt-get -y install libgl1-mesa-glx \
                     libgl1-mesa-dri

ENTRYPOINT gazebo
